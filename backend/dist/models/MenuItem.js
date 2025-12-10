import mongoose, { Schema } from 'mongoose';
const menuItemSchema = new Schema({
    name: { type: String, required: true },
    description: { type: String },
    price: { type: Number, required: true },
    category: { type: String, required: true }, // e.g., 'Appetizers', 'Main Course'
    imageUrl: { type: String },
    isActive: { type: Boolean, default: true },
    allergens: [{ type: String }],
}, { timestamps: true });
export const MenuItem = mongoose.model('MenuItem', menuItemSchema);
