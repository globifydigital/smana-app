import asyncHandler from 'express-async-handler';
import { MenuItem } from '../models/MenuItem.js';
import { socketService } from '../services/socketService.js';
// @desc    Get all menu items
// @route   GET /api/menu
// @access  Public
export const getMenu = asyncHandler(async (req, res) => {
    const menuItems = await MenuItem.find({ isActive: true });
    res.json(menuItems);
});
// @desc    Get all menu items (Admin)
// @route   GET /api/menu/admin
// @access  Private/Admin
export const getMenuAdmin = asyncHandler(async (req, res) => {
    const menuItems = await MenuItem.find({});
    res.json(menuItems);
});
// @desc    Create menu item
// @route   POST /api/menu
// @access  Private/Admin
export const createMenuItem = asyncHandler(async (req, res) => {
    // Body parsing might need manual handling if multipart/form-data
    // For now assuming body has correct types or parsing happens before
    // If using multer, req.body will be populated, but fields might be strings.
    // Manual cast if coming from form-data usually needs care, but Zod can validate
    const { name, price, category, description, allergens } = req.body;
    const imageUrl = req.file ? req.file.path : '';
    const menuItem = await MenuItem.create({
        name,
        price: Number(price),
        category,
        description,
        allergens: allergens ? (typeof allergens === 'string' ? JSON.parse(allergens) : allergens) : [],
        imageUrl
    });
    if (menuItem) {
        socketService.emit('menu-updated', menuItem);
        res.status(201).json(menuItem);
    }
    else {
        res.status(400);
        throw new Error('Invalid menu data');
    }
});
// @desc    Update menu item
// @route   PUT /api/menu/:id
// @access  Private/Admin
export const updateMenuItem = asyncHandler(async (req, res) => {
    const menuItem = await MenuItem.findById(req.params.id);
    if (menuItem) {
        menuItem.name = req.body.name || menuItem.name;
        menuItem.price = req.body.price ? Number(req.body.price) : menuItem.price;
        menuItem.category = req.body.category || menuItem.category;
        menuItem.description = req.body.description || menuItem.description;
        menuItem.isActive = req.body.isActive !== undefined ? req.body.isActive : menuItem.isActive;
        if (req.body.allergens) {
            menuItem.allergens = typeof req.body.allergens === 'string' ? JSON.parse(req.body.allergens) : req.body.allergens;
        }
        if (req.file) {
            menuItem.imageUrl = req.file.path;
        }
        const updatedMenuItem = await menuItem.save();
        socketService.emit('menu-updated', updatedMenuItem);
        res.json(updatedMenuItem);
    }
    else {
        res.status(404);
        throw new Error('Menu item not found');
    }
});
// @desc    Delete menu item
// @route   DELETE /api/menu/:id
// @access  Private/Admin
export const deleteMenuItem = asyncHandler(async (req, res) => {
    const menuItem = await MenuItem.findById(req.params.id);
    if (menuItem) {
        await menuItem.deleteOne();
        socketService.emit('menu-updated', { id: req.params.id, deleted: true });
        res.json({ message: 'Menu item removed' });
    }
    else {
        res.status(404);
        throw new Error('Menu item not found');
    }
});
