import jwt from 'jsonwebtoken';
import { Staff } from '../models/Staff.js';
import { Guest } from '../models/Guest.js';
const protect = async (req, res, next) => {
    let token;
    token = req.cookies.jwt;
    if (token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || '');
            // Try finding in Staff first, then Guest
            let user = await Staff.findById(decoded.userId).select('-password');
            if (!user) {
                user = await Guest.findById(decoded.userId);
            }
            if (!user) {
                res.status(401);
                throw new Error('Not authorized, user not found');
            }
            req.user = user;
            next();
        }
        catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Not authorized, token failed' });
        }
    }
    else {
        res.status(401).json({ message: 'Not authorized, no token' });
    }
};
const admin = (req, res, next) => {
    if (req.user && req.user.role === 'Admin') {
        next();
    }
    else {
        res.status(401).json({ message: 'Not authorized as an admin' });
    }
};
export { protect, admin };
