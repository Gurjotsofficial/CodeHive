const mongoose = require('mongoose');

// importing database usrl
require('dotenv').config();

const dbConnect = () => {
    mongoose.connect(process.env.DATABASE_URL)
    .then( () => console.log('DB CONNECTION SUCCESSFUL') )
    .catch( (error) => {
        console.log('Error in DB CONNECTION');
        console.log(error.message);
        process.exit(1);
    });
} 

module.exports = dbConnect;