import { Request, Response } from 'express';
import asyncHandler from 'express-async-handler';
import { hyperPayService, CheckoutRequest } from '../services/hyperpay.service.js';
import { FoodOrder } from '../models/FoodOrder.js';
import { MenuItem } from '../models/MenuItem.js';
import { z } from 'zod';

// Validation schemas
const createCheckoutSchema = z.object({
    items: z.array(z.object({
        menuItemId: z.string(),
        quantity: z.number().min(1)
    })),
    roomNumber: z.string(),
    notes: z.string().optional(),
    currency: z.enum(['AED', 'USD']).default('AED'),
    customerEmail: z.string().email(),
    billingAddress: z.object({
        givenName: z.string().min(1),
        surname: z.string().min(1),
        street1: z.string().min(1),
        city: z.string().min(1),
        state: z.string().min(1),
        country: z.string().length(2), // ISO Alpha-2 country code
        postcode: z.string().min(1)
    })
});

// @desc    Create HyperPay checkout session and prepare order
// @route   POST /api/payments/checkout
// @access  Private
export const createCheckout = asyncHandler(async (req: Request, res: Response) => {
    const result = createCheckoutSchema.safeParse(req.body);

    if (!result.success) {
        res.status(400);
        throw new Error('Invalid checkout data: ' + result.error.message);
    }

    const { items, roomNumber, notes, currency, customerEmail, billingAddress } = result.data;
    const userId = (req.user as any)._id;

    // Calculate total and prepare order items
    let totalAmount = 0;
    const orderItems: any[] = [];

    for (const item of items) {
        const menuItem = await MenuItem.findById(item.menuItemId);
        if (!menuItem) {
            res.status(400);
            throw new Error(`Menu item not found: ${item.menuItemId}`);
        }

        const itemTotal = menuItem.price * item.quantity;
        totalAmount += itemTotal;

        orderItems.push({
            menuItemId: menuItem._id,
            name: menuItem.name,
            quantity: item.quantity,
            price: menuItem.price
        });
    }

    try {
        // Create pending order (not confirmed until payment succeeds)
        const order = await FoodOrder.create({
            guestId: userId,
            roomNumber,
            items: orderItems,
            totalAmount,
            notes,
            paymentMethod: 'HyperPay',
            paymentStatus: 'pending',
            currency,
            status: 'Pending'
        });

        const checkoutData: CheckoutRequest = {
            amount: totalAmount.toFixed(2),
            currency,
            paymentType: 'DB',
            merchantTransactionId: order._id.toString(),
            customerEmail,
            billingAddress
        };

        const checkoutResponse = await hyperPayService.createCheckout(checkoutData);

        // Update order with checkout ID
        order.checkoutId = checkoutResponse.id;
        await order.save();

        res.status(200).json({
            success: true,
            checkoutId: checkoutResponse.id,
            orderId: order._id.toString(),
            amount: totalAmount.toFixed(2),
            currency,
            result: checkoutResponse.result
        });
    } catch (error: any) {
        console.error('Checkout creation error:', error);
        res.status(500);
        throw new Error(error.message || 'Failed to create checkout');
    }
});

// @desc    Get payment status
// @route   GET /api/payments/status/:checkoutId
// @access  Private
export const getPaymentStatus = asyncHandler(async (req: Request, res: Response) => {
    const { checkoutId } = req.params;

    if (!checkoutId) {
        res.status(400);
        throw new Error('Checkout ID is required');
    }

    // Find order with this checkout ID
    const order = await FoodOrder.findOne({ checkoutId });
    if (!order) {
        res.status(404);
        throw new Error('Order not found for this checkout ID');
    }

    // Verify order belongs to current user
    const userId = (req.user as any)._id;
    if (order.guestId.toString() !== userId.toString()) {
        res.status(403);
        throw new Error('Not authorized to access this payment');
    }

    try {
        const currency = order.currency || 'AED';
        const paymentStatus = await hyperPayService.getPaymentStatus(checkoutId, currency);

        // Update order based on payment status
        const isSuccess = hyperPayService.isPaymentSuccessful(paymentStatus.result.code);
        const isPending = hyperPayService.isPaymentPending(paymentStatus.result.code);

        if (isSuccess) {
            order.paymentStatus = 'success';
            order.transactionId = paymentStatus.id;
            order.paymentResponse = paymentStatus;
            order.status = 'Pending'; // Confirmed order, kitchen will process
            await order.save();

            // Emit socket event for new order
            const { socketService } = await import('../services/socketService.js');
            const populatedOrder = await order.populate('guestId', 'name');
            socketService.emit('new-food-order', populatedOrder);
        } else if (!isPending) {
            order.paymentStatus = 'failed';
            order.paymentResponse = paymentStatus;
            order.status = 'Cancelled'; // Cancel failed payment orders
            await order.save();
        }

        res.status(200).json({
            success: isSuccess,
            pending: isPending,
            paymentStatus: isSuccess ? 'success' : isPending ? 'pending' : 'failed',
            result: paymentStatus.result,
            transactionId: paymentStatus.id,
            paymentBrand: paymentStatus.paymentBrand,
            amount: paymentStatus.amount,
            currency: paymentStatus.currency,
            orderId: order._id.toString()
        });
    } catch (error: any) {
        console.error('Payment status error:', error);
        res.status(500);
        throw new Error(error.message || 'Failed to get payment status');
    }
});

// @desc    Update payment status (webhook/callback)
// @route   POST /api/payments/callback/:orderId
// @access  Public (but should be validated)
export const paymentCallback = asyncHandler(async (req: Request, res: Response) => {
    const { orderId } = req.params;
    const { checkoutId } = req.body;

    const order = await FoodOrder.findById(orderId);
    if (!order) {
        res.status(404);
        throw new Error('Order not found');
    }

    if (order.checkoutId !== checkoutId) {
        res.status(400);
        throw new Error('Checkout ID mismatch');
    }

    try {
        const currency = order.currency || 'AED';
        const paymentStatus = await hyperPayService.getPaymentStatus(checkoutId, currency);

        const isSuccess = hyperPayService.isPaymentSuccessful(paymentStatus.result.code);

        if (isSuccess) {
            order.paymentStatus = 'success';
            order.transactionId = paymentStatus.id;
            order.paymentResponse = paymentStatus;
        } else {
            order.paymentStatus = 'failed';
            order.paymentResponse = paymentStatus;
        }

        await order.save();

        res.status(200).json({
            success: true,
            paymentStatus: order.paymentStatus,
            orderId: order._id
        });
    } catch (error: any) {
        console.error('Payment callback error:', error);
        res.status(500);
        throw new Error(error.message || 'Failed to process payment callback');
    }
});
