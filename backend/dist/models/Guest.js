import mongoose, { Schema } from 'mongoose';
const guestSchema = new Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    roomNumber: { type: String }, // Can be null if not yet assigned or booked
    isCheckedIn: { type: Boolean, default: false },
    checkInDate: { type: Date },
    checkOutDate: { type: Date },
}, { timestamps: true });
export const Guest = mongoose.model('Guest', guestSchema);
