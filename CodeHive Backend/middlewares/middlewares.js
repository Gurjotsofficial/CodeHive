const jwt = require('jsonwebtoken');
require('dotenv').config();

exports.isValidUser = async(req , res , next) => {
    try{
        const authHeader = req.header("Authorization");
        
        const token = req.cookies?.token ||
        req.body?.token ||
        (authHeader && authHeader.startsWith("Bearer ")
        ? authHeader.replace("Bearer ", "")
        : null);
        
        // console.log("RAW AUTH HEADER:", req.header("Authorization"));
        // console.log("TOKEN TO VERIFY:", token);
        // console.log("cookies ->" , req.headers.cookie);
        // const token =  req.cookies.token ;

        if(!token || token === undefined){
            return res.status(404).json({
                success:false,
                message:"Token not found"
            })
        } 

        // Verfication of the token
        try{
            const decode =  jwt.verify(token, process.env.JWT_SECRET);
            // console.log(decode);

            // Why do we need this?
            req.loginuser = decode;
            
            // We put the decode thing in loginuser so that we can access the details of loginuser in the further middlewares

        }catch(err){
            return res.status(401).json({
                success : false,
                message: "Token is Invalid"
            })
        }

        next();
    }catch(error){
        console.log(error);
        return res.status(401).json({
            success : false,
            message: "Something Went Wrong!!!",
        })
    }
}