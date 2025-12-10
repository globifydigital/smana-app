import asyncHandler from 'express-async-handler';
import { Guest } from '../models/Guest.js';
import { Room } from '../models/Room.js';
import { socketService } from '../services/socketService.js';
import { registerGuestSchema } from '../validation/schemas.js';
import generateToken from '../utils/generateToken.js';
// @desc    Register a new guest (Public) - Appears in admin
// @route   POST /api/guests/register
// @access  Public
export const registerGuest = asyncHandler(async (req, res) => {
    const { name, email, phone } = req.body;
    // Validate
    const validation = registerGuestSchema.safeParse({ name, email, phone });
    if (!validation.success) {
        res.status(400);
        throw new Error(validation.error.message);
    }
    let guest = await Guest.findOne({ email });
    if (guest) {
        // Update existing info if not checked in? Or just return it?
        // Let's update details
        guest.name = name;
        guest.phone = phone;
        await guest.save();
    }
    else {
        guest = await Guest.create({
            name,
            email,
            phone,
            isCheckedIn: false, // Not checked in yet
        });
    }
    // Generate token so they are "logged in" as a Guest User (but not checked into room)
    generateToken(res, guest._id.toString());
    socketService.emit('guest-registered', guest);
    res.status(201).json({
        _id: guest._id,
        name: guest.name,
        email: guest.email,
        phone: guest.phone,
        isCheckedIn: guest.isCheckedIn
    });
});
// @desc    Register a new guest (or find existing) and check them in
// @route   POST /api/guests/check-in
// @access  Private/Staff
export const checkInGuest = asyncHandler(async (req, res) => {
    // Expect details + roomNumber
    // If guest exists by email, update them. Else create.
    const { name, email, phone, roomNumber, checkOutDate } = req.body;
    const validation = registerGuestSchema.safeParse({ name, email, phone });
    if (!validation.success) {
        res.status(400);
        throw new Error(validation.error.message);
    }
    let guest = await Guest.findOne({ email });
    if (guest) {
        guest.name = name;
        guest.phone = phone;
        guest.roomNumber = roomNumber;
        guest.isCheckedIn = true;
        guest.checkInDate = new Date();
        guest.checkOutDate = checkOutDate ? new Date(checkOutDate) : undefined;
        await guest.save();
    }
    else {
        guest = await Guest.create({
            name,
            email,
            phone,
            roomNumber,
            isCheckedIn: true,
            checkInDate: new Date(),
            checkOutDate: checkOutDate ? new Date(checkOutDate) : undefined
        });
    }
    // Update Room status
    const room = await Room.findOne({ roomNumber });
    if (room) {
        room.status = 'Occupied';
        room.currentGuestId = guest._id;
        await room.save();
        socketService.emit('room-status-changed', room);
    }
    socketService.emit('guest-checked-in', guest);
    res.status(201).json(guest);
});
// @desc    Check out guest
// @route   POST /api/guests/check-out/:id
// @access  Private/Staff
export const checkOutGuest = asyncHandler(async (req, res) => {
    const guest = await Guest.findById(req.params.id);
    if (guest && guest.isCheckedIn) {
        const roomNumber = guest.roomNumber;
        guest.isCheckedIn = false;
        guest.roomNumber = undefined;
        await guest.save();
        if (roomNumber) {
            const room = await Room.findOne({ roomNumber });
            if (room) {
                room.status = 'Cleaning'; // Set to cleaning after checkout
                room.currentGuestId = undefined;
                await room.save();
                socketService.emit('room-status-changed', room);
            }
        }
        socketService.emit('guest-checked-out', guest);
        res.json({ message: 'Guest checked out successfully' });
    }
    else {
        res.status(404);
        throw new Error('Guest not found or already checked out');
    }
});
// @desc    Get all guests
// @route   GET /api/guests
// @access  Private/Staff
export const getGuests = asyncHandler(async (req, res) => {
    const guests = await Guest.find({}).sort({ updatedAt: -1 });
    res.json(guests);
});
// @desc    Guest Login (via Room Number and Email)
// @route   POST /api/guests/login
// @access  Public
export const loginGuest = asyncHandler(async (req, res) => {
    const { roomNumber, email } = req.body;
    // Find active guest
    const guest = await Guest.findOne({ roomNumber, email, isCheckedIn: true });
    if (guest) {
        generateToken(res, guest._id.toString());
        res.json({
            _id: guest._id,
            name: guest.name,
            email: guest.email,
            roomNumber: guest.roomNumber,
            isCheckedIn: guest.isCheckedIn
        });
    }
    else {
        res.status(401);
        throw new Error('Invalid room number or email, or not checked in');
    }
});
