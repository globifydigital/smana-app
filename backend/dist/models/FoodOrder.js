import mongoose, { Schema } from 'mongoose';
const orderItemSchema = new Schema({
    menuItemId: { type: Schema.Types.ObjectId, ref: 'MenuItem', required: true },
    name: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    price: { type: Number, required: true }, // Price at time of order
}, { _id: false });
const foodOrderSchema = new Schema({
    guestId: { type: Schema.Types.ObjectId, ref: 'Guest', required: true },
    roomNumber: { type: String, required: true },
    items: [orderItemSchema],
    totalAmount: { type: Number, required: true },
    status: {
        type: String,
        enum: ['Pending', 'preparing', 'Ready', 'Delivered', 'Cancelled'],
        default: 'Pending',
    },
    notes: { type: String },
}, { timestamps: true });
export const FoodOrder = mongoose.model('FoodOrder', foodOrderSchema);
