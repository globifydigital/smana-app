import express from 'express';
import path from 'path';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import { createServer } from 'http';
import connectDB from './config/db.js';
import { notFound, errorHandler } from './middlewares/errorMiddleware.js';
import { socketService } from './services/socketService.js';
// Routes
import authRoutes from './routes/authRoutes.js';
import roomRoutes from './routes/roomRoutes.js';
import menuRoutes from './routes/menuRoutes.js';
import orderRoutes from './routes/orderRoutes.js';
import serviceRoutes from './routes/serviceRoutes.js';
import guestRoutes from './routes/guestRoutes.js';
import uploadRoutes from './routes/uploadRoutes.js';
import staffRoutes from './routes/staffRoutes.js';
dotenv.config();
connectDB();
const app = express();
const httpServer = createServer(app);
// Initialize Socket.io
socketService.init(httpServer);
// Middleware
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
    origin: [process.env.CLIENT_URL || 'http://localhost:3000', 'http://localhost:3001', 'http://localhost:3005'],
    credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
}
// Static folder
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));
// Routes
app.use('/api/auth', authRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/service-requests', serviceRoutes);
app.use('/api/guests', guestRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/staff', staffRoutes);
app.get('/', (req, res) => {
    res.send('API is running...');
});
// Error Handling
app.use(notFound);
app.use(errorHandler);
const PORT = process.env.PORT || 5000;
httpServer.listen(PORT, () => {
    console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
