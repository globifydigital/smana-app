import mongoose, { Schema } from 'mongoose';
const serviceRequestSchema = new Schema({
    guestId: { type: Schema.Types.ObjectId, ref: 'Guest', required: true },
    roomNumber: { type: String, required: true },
    type: { type: String, required: true },
    message: { type: String },
    priority: {
        type: String,
        enum: ['Low', 'Medium', 'High'],
        default: 'Medium',
    },
    status: {
        type: String,
        enum: ['Open', 'In_Progress', 'Resolved', 'Cancelled'],
        default: 'Open',
    },
    handledBy: { type: Schema.Types.ObjectId, ref: 'Staff' },
}, { timestamps: true });
export const ServiceRequest = mongoose.model('ServiceRequest', serviceRequestSchema);
