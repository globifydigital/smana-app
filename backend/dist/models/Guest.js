import mongoose, { Schema } from 'mongoose';
const guestSchema = new Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String }, // Store hashed
    phone: { type: String, required: true },
    roomNumber: { type: String }, // Can be null if not yet assigned or booked
    isCheckedIn: { type: Boolean, default: false },
    checkInDate: { type: Date },
    checkOutDate: { type: Date },
}, { timestamps: true });
import bcrypt from 'bcryptjs';
guestSchema.methods.matchPassword = async function (enteredPassword) {
    if (!this.password)
        return false;
    return await bcrypt.compare(enteredPassword, this.password);
};
guestSchema.pre('save', async function () {
    if (!this.isModified('password') || !this.password) {
        return;
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});
export const Guest = mongoose.model('Guest', guestSchema);
