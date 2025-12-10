import { Request, Response } from 'express';
import asyncHandler from 'express-async-handler';
import { FoodOrder, IOrderItem } from '../models/FoodOrder.js';
import { MenuItem } from '../models/MenuItem.js';
import { createOrderSchema } from '../validation/schemas.js';
import { socketService } from '../services/socketService.js';
import mongoose from 'mongoose';

// @desc    Place a new food order
// @route   POST /api/orders
// @access  Private (Guest/Staff)
export const placeOrder = asyncHandler(async (req: Request, res: Response) => {
    // Basic validation of body structure
    const result = createOrderSchema.safeParse(req.body);
    if (!result.success) {
        res.status(400);
        throw new Error('Invalid order data: ' + result.error.message);
    }

    // In a real app we would get guestId from req.user (jwt)
    // For now assuming req.user is populated by middleware
    // If guest is not logged in but just supplying roomNumber, we might need logic to find active guest for room.
    // Assuming authenticated flow:

    const { roomNumber, items: rawItems, notes, paymentMethod } = result.data;
    const guestId = req.user ? (req.user as any)._id : null; // Should handle this better if public

    if (!guestId) {
        res.status(401);
        throw new Error('User not authenticated');
    }

    let totalAmount = 0;
    const orderItems: IOrderItem[] = [];

    // Verify items and calculate total
    for (const item of rawItems) {
        const menuItem = await MenuItem.findById(item.menuItemId);
        if (!menuItem) {
            res.status(400);
            throw new Error(`Menu item not found: ${item.menuItemId}`);
        }

        const itemTotal = menuItem.price * item.quantity;
        totalAmount += itemTotal;

        orderItems.push({
            menuItemId: menuItem._id as mongoose.Types.ObjectId,
            name: menuItem.name,
            quantity: item.quantity,
            price: menuItem.price
        });
    }

    const order = await FoodOrder.create({
        guestId,
        roomNumber,
        items: orderItems,
        totalAmount,
        totalAmount,
        notes,
        paymentMethod
    });

    if (order) {
        // Populate guest details for the socket event if needed
        const populatedOrder = await order.populate('guestId', 'name');
        socketService.emit('new-food-order', populatedOrder);
        res.status(201).json(populatedOrder);
    } else {
        res.status(400);
        throw new Error('Invalid order data');
    }
});

// @desc    Get all orders (Staff)
// @route   GET /api/orders
// @access  Private/Staff
export const getOrders = asyncHandler(async (req: Request, res: Response) => {
    const orders = await FoodOrder.find({})
        .populate('guestId', 'name')
        .sort({ createdAt: -1 });
    res.json(orders);
});

// @desc    Get orders for a guest
// @route   GET /api/orders/my
// @access  Private
export const getMyOrders = asyncHandler(async (req: Request, res: Response) => {
    const orders = await FoodOrder.find({ guestId: (req.user as any)._id }).sort({ createdAt: -1 });
    res.json(orders);
});

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private/Staff
export const updateOrderStatus = asyncHandler(async (req: Request, res: Response) => {
    const { status } = req.body;
    const order = await FoodOrder.findById(req.params.id);

    if (order) {
        order.status = status;
        const updatedOrder = await order.save();
        socketService.emit('order-status-changed', updatedOrder);
        res.json(updatedOrder);
    } else {
        res.status(404);
        throw new Error('Order not found');
    }
});
