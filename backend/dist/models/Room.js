import mongoose, { Schema } from 'mongoose';
const roomSchema = new Schema({
    roomNumber: { type: String, required: true, unique: true },
    type: {
        type: String,
        enum: ['Standard', 'Deluxe', 'Suite', 'Royal'],
        default: 'Standard',
    },
    status: {
        type: String,
        enum: ['Available', 'Occupied', 'Cleaning', 'Maintenance'],
        default: 'Available',
    },
    floor: { type: Number, required: true },
    currentGuestId: { type: Schema.Types.ObjectId, ref: 'Guest' },
}, { timestamps: true });
export const Room = mongoose.model('Room', roomSchema);
