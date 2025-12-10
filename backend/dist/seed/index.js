import dotenv from 'dotenv';
import { Room } from '../models/Room.js';
import { MenuItem } from '../models/MenuItem.js';
import { Staff } from '../models/Staff.js';
import { Guest } from '../models/Guest.js';
import connectDB from '../config/db.js';
dotenv.config();
connectDB();
const importData = async () => {
    try {
        await Room.deleteMany();
        await MenuItem.deleteMany();
        await Staff.deleteMany();
        await Guest.deleteMany();
        // STAFF
        const staffMembers = [
            { name: 'Admin User', email: 'admin@smana.com', password: 'password123', role: 'Admin', isOnline: false },
            { name: 'Receptionist User', email: 'reception@smana.com', password: 'password123', role: 'Receptionist', isOnline: false },
            { name: 'Chef Gordon', email: 'chef@smana.com', password: 'password123', role: 'Chef', isOnline: false },
            { name: 'Housekeeper Anna', email: 'housekeeping@smana.com', password: 'password123', role: 'Housekeeping', isOnline: false },
            { name: 'Manager John', email: 'manager@smana.com', password: 'password123', role: 'Manager', isOnline: false },
        ];
        await Staff.create(staffMembers);
        console.log('Staff imported!');
        // ROOMS
        const rooms = [];
        const roomTypes = ['Standard', 'Deluxe', 'Suite', 'Royal'];
        // 5 floors, 20 rooms each
        for (let floor = 1; floor <= 5; floor++) {
            for (let r = 1; r <= 20; r++) {
                const roomNum = floor * 100 + r;
                const typeIndex = Math.floor(Math.random() * roomTypes.length);
                rooms.push({
                    roomNumber: roomNum.toString(),
                    type: roomTypes[typeIndex],
                    floor: floor,
                    status: 'Available'
                });
            }
        }
        await Room.create(rooms);
        console.log('Rooms imported!');
        // MENU ITEMS
        const menuItems = [];
        const categories = ['Appetizer', 'Main Course', 'Dessert', 'Beverage'];
        for (let i = 1; i <= 50; i++) {
            const catIndex = Math.floor(Math.random() * categories.length);
            menuItems.push({
                name: `Lux Dish ${i}`,
                description: `A delicious luxury dish number ${i}`,
                price: Math.floor(Math.random() * 500) + 50,
                category: categories[catIndex],
                isActive: true,
                imageUrl: 'https://via.placeholder.com/150',
                allergens: i % 2 === 0 ? ['Gluten'] : []
            });
        }
        await MenuItem.create(menuItems);
        console.log('Menu Items imported!');
        console.log('Data Imported!');
        process.exit();
    }
    catch (error) {
        console.error(`Error: ${error}`);
        process.exit(1);
    }
};
const destroyData = async () => {
    // ... impl if needed
};
if (process.argv[2] === '-d') {
    destroyData();
}
else {
    importData();
}
