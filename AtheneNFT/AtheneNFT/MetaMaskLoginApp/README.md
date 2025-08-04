### Project Structure

```
my-dapp/
├── client/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── Login.js
│   │   │   ├── Profile.js
│   │   ├── App.js
│   │   ├── index.js
│   │   └── web3.js
│   ├── package.json
│   └── .env
├── server/
│   ├── models/
│   │   └── User.js
│   ├── routes/
│   │   └── user.js
│   ├── config/
│   │   └── db.js
│   ├── server.js
│   ├── package.json
│   └── .env
└── README.md
```

### Step 1: Setting Up the Client

1. **Create React App**:
   ```bash
   npx create-react-app client
   cd client
   ```

2. **Install Dependencies**:
   ```bash
   npm install web3 axios
   ```

3. **Create Web3 Instance**:
   Create a file `src/web3.js` to initialize Web3.
   ```javascript
   import Web3 from 'web3';

   const web3 = new Web3(window.ethereum);

   export default web3;
   ```

4. **Create Login Component**:
   Create `src/components/Login.js`.
   ```javascript
   import React, { useState } from 'react';
   import web3 from '../web3';
   import axios from 'axios';

   const Login = () => {
       const [account, setAccount] = useState('');

       const connectMetaMask = async () => {
           if (window.ethereum) {
               try {
                   const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
                   setAccount(accounts[0]);
                   // Send account to backend to create or fetch user profile
                   await axios.post('http://localhost:5000/api/user', { address: accounts[0] });
               } catch (error) {
                   console.error(error);
               }
           } else {
               alert('Please install MetaMask!');
           }
       };

       return (
           <div>
               <h1>Login with MetaMask</h1>
               <button onClick={connectMetaMask}>Connect MetaMask</button>
               {account && <p>Connected Account: {account}</p>}
           </div>
       );
   };

   export default Login;
   ```

5. **Create Profile Component**:
   Create `src/components/Profile.js`.
   ```javascript
   import React from 'react';

   const Profile = ({ user }) => {
       return (
           <div>
               <h1>User Profile</h1>
               <p>Address: {user.address}</p>
               {/* Add more user details here */}
           </div>
       );
   };

   export default Profile;
   ```

6. **Update App Component**:
   Update `src/App.js`.
   ```javascript
   import React from 'react';
   import Login from './components/Login';

   const App = () => {
       return (
           <div>
               <Login />
           </div>
       );
   };

   export default App;
   ```

7. **Run the Client**:
   ```bash
   npm start
   ```

### Step 2: Setting Up the Server

1. **Create Server Directory**:
   Create a new directory for the server.
   ```bash
   mkdir server
   cd server
   npm init -y
   ```

2. **Install Dependencies**:
   ```bash
   npm install express mongoose cors dotenv
   ```

3. **Create Database Connection**:
   Create `server/config/db.js`.
   ```javascript
   const mongoose = require('mongoose');
   const dotenv = require('dotenv');

   dotenv.config();

   const connectDB = async () => {
       try {
           await mongoose.connect(process.env.MONGO_URI, {
               useNewUrlParser: true,
               useUnifiedTopology: true,
           });
           console.log('MongoDB connected');
       } catch (error) {
           console.error(error.message);
           process.exit(1);
       }
   };

   module.exports = connectDB;
   ```

4. **Create User Model**:
   Create `server/models/User.js`.
   ```javascript
   const mongoose = require('mongoose');

   const UserSchema = new mongoose.Schema({
       address: { type: String, required: true, unique: true },
       // Add more fields as needed
   });

   module.exports = mongoose.model('User', UserSchema);
   ```

5. **Create User Routes**:
   Create `server/routes/user.js`.
   ```javascript
   const express = require('express');
   const User = require('../models/User');
   const router = express.Router();

   router.post('/', async (req, res) => {
       const { address } = req.body;
       try {
           let user = await User.findOne({ address });
           if (!user) {
               user = new User({ address });
               await user.save();
           }
           res.json(user);
       } catch (error) {
           res.status(500).send('Server Error');
       }
   });

   module.exports = router;
   ```

6. **Set Up Server**:
   Create `server/server.js`.
   ```javascript
   const express = require('express');
   const connectDB = require('./config/db');
   const cors = require('cors');
   const userRoutes = require('./routes/user');
   const dotenv = require('dotenv');

   dotenv.config();
   const app = express();

   connectDB();

   app.use(cors());
   app.use(express.json());
   app.use('/api/user', userRoutes);

   const PORT = process.env.PORT || 5000;
   app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
   ```

7. **Run the Server**:
   Make sure to set your MongoDB URI in a `.env` file in the server directory.
   ```plaintext
   MONGO_URI=your_mongodb_uri
   ```

   Then run:
   ```bash
   node server.js
   ```

### Step 3: Testing the Application

1. Start the server and client.
2. Open your browser and navigate to `http://localhost:3000`.
3. Click the "Connect MetaMask" button to authenticate with MetaMask.
4. Check your MongoDB database to see if the user is created or fetched.

### Conclusion

This is a basic setup for a login page using MetaMask for authentication and a simple backend to manage user profiles. You can expand this project by adding more features, such as user profile editing, displaying additional user information, and improving the UI with CSS or a UI framework like Material-UI or Bootstrap.