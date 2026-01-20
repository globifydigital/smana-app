import mongoose, { Schema } from 'mongoose';
const feedbackSchema = new Schema({
    guestId: { type: Schema.Types.ObjectId, ref: 'Guest', required: true },
    roomNumber: { type: String, required: true },
    name: { type: String, required: true },
    email: { type: String },
    phone: { type: String },
    rating: { type: Number, required: true, min: 1, max: 5 },
    description: { type: String, required: true },
}, { timestamps: true });
export const Feedback = mongoose.model('Feedback', feedbackSchema);
