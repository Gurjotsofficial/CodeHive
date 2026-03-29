const userSchema = require('../models/models');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Signup Route Handler
exports.signUp = async(req , res) => {
    try{
        // extracting name email and password from request.body
        const {name, email, password, confirmPassword} = req.body;

        // checking if all details are filled
        if(!name || !email || !password){
            return res.status(400).json({
                success:false,
                message:'please fill all the details'
            });
        }

        // // checking if user doesnt exist already
        const alreadyExistingUser = await userSchema.findOne({email});
        if(alreadyExistingUser){
             return res.status(401).json({
                success:false,
                message:'Sorry user already exists'
            });
        }

        // checking if password and confirm password are same
        if(password != confirmPassword){
            return res.json({
                success: false,
                message: "Please enter same password in both the fields"
            })
        }

        // hashing the passwords
        let hashPassword;
        try{
            hashPassword = await bcrypt.hash(password,10);
        }catch(err){
            return res.json({
                success : false,
                message: 'error in hashing password'
            });
        }

        const user = await userSchema.create({name, email, password : hashPassword});
        const payload = {
            name : user.name,
            email : user.email,
            id : user._id
        };
        const token = await jwt.sign(payload, process.env.JWT_SECRET,{
            expiresIn : "3h"
        });

        user.token = token;
        return res.status(200).json({
            success : true,
            data: payload,
            token,
            message : 'User has been created successfully'
        })

    }catch(error){
        console.error(error);
        return res.status(500).json(
            {
                success: false,
                data: 'error in creating user',
                message: error.message 
            }
        )


    }
}



// Login Route Handler
exports.login = async(req,res) => {
    try{
        // fetching email and password from user
        const {email,password} = req.body;

        //checking if both details were given
        if(!email || !password){
              return res.status(400).json({
                success:false,
                message:'please fill both the details'
            });
        }

        // checking if user exists
        const existingUser = await userSchema.findOne({email});
        if(!existingUser){
             return res.status(401).json({
                success:false,
                message:'Sorry User does not exist'
            });
        }
        const payload = {
            name: existingUser.name,
            email: existingUser.email,
            id: existingUser._id,
        }
        // does password match
        const doesPasswordMatch = await bcrypt.compare(password , existingUser.password);

        if(doesPasswordMatch){
             const token = jwt.sign(payload, process.env.JWT_SECRET,{
                expiresIn : "3h"
             })
             existingUser.token = token;
             existingUser.password = undefined;
            return res.status(200).json({
                success:true,
                token,
                existingUser,
                message:'User logged in successfully'
            });
        }else {
            return res.status(403).json({
                success: false,
                message: 'Sorry the password doesnt match'
            })
        }
            
        
    }catch(error){
        console.error(error);
        return res.status(500).json(
            {
                success: false,
                data: 'error in logging in',
                message: error.message 
            }
        )
    }


}