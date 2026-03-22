const express = require('express');
const router = express.Router();
const USER = require('../models/models');
const WORKSPACE = require('../models/workspace_model');
const DOCUMENT = require('../models/document_model');

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');



// importing the route handlers
const {signUp, login} = require('../controllers/controllers');
const {isValidUser} = require('../middlewares/middlewares');
const { errorMonitor } = require('events');

// setting routes
router.post("/signup", signUp);
router.post("/login", login);

// protected routes
router.get("/test", isValidUser);


// Workspace route





// Other protected routes
router.get("/me", isValidUser, async(req , res) => {
    try{
        // fetching id of user from the middleware
        const id = req.loginuser.id;

        // fetching the user from database using the fetched id
        const user = await USER.findById(id);
        if(!user){
            return res.status(404).json({
                success : false,
                message : "User not found"
            });
        }
        // undefining the password of user in this instance
        user.password = undefined; // is there a more professional way to do this 


        return res.status(200).json({
            success : true,
            user : user,
            message : "Welcome to Collabrative Code Editor"
        })
    }catch(e){
        console.error(e);
        return res.status(500).json({
        success:false,
        message: "Error in fetching id",
        })
    };
});


// Workspace route
router.post('/create_workspace', isValidUser ,async(req,res) => {
    console.log("🔥 CREATE WORKSPACE ROUTE FILE HIT 🔥");
    try{
        const {name} = req.body;
        // console.log('login user : ', req.loginuser);
        const owner_id = req.loginuser.id;

        const workspace = await WORKSPACE.create({name, owner_id});
        
                return res.status(201).json({
                    success : true,
                    workspace : workspace,
                    message : "WorkSpace Created Successfully"
                });

    }catch(e){
        console.error(e);
        return res.status(500).json({
            success : false,
            message : "Failed to create workspace"
        });
    }
});



// Find workspaces
router.get('/get_workspace', isValidUser ,async(req,res) => {
    try{
        const owner_id = req.loginuser.id;

        const workspace = await WORKSPACE.find({owner_id});
        
                return res.status(200).json({
                    success : true,
                    workspace : workspace,
                    message : "WorkSpaces Fetched Successfully"
                });

    }catch(e){
        console.error(e);
        return res.status(500).json({
            success : false,
            message : "Failed to fetch workspaces"
        });
    }
});

router.get('/join_room/:workspace_id', isValidUser, async(req,res) => {
    try{
        const workspace_id = req.params.workspace_id;
        if(!workspace_id){
            return res.status(400).json({
                success:false,
                message:'Please enter a Workspace Id'
            });
        }
        const workspace = await WORKSPACE.findById(workspace_id);
        if(!workspace){
            return res.status(404).json({
                success:false,
                message:'Room doesn\'t exist'
            })
        }
        return res.status(200).json({
            success : true,
            workspace : workspace,
            message : 'Room fetched Successfully'
        })

    }catch(e){
        console.error(e)
        return res.status(500).json({
                success : false,
                message : "Error in joining room"
            })
    }
})



// Workspace Documents Routes
// Create Document Route Handler
router.post('/createWorkspaceDocument/:workspace_id', isValidUser, async(req,res) => {
    try{
        const workspace_id = req.params.workspace_id;
        const{name} = req.body;
        const workspace = await WORKSPACE.findById(workspace_id);
        const owner_id = req.loginuser.id;

        if (!workspace) {
        return res.status(404).json({
        success: false,
        message: "Workspace not found",
        });
        }


        if (!name || name.trim() === "") {
        return res.status(400).json({
        success: false,
        message: "Document name is required",
        });
        }

        if(workspace.owner_id.toString() == owner_id.toString()){

            const newDocument = await DOCUMENT.create({name, workspace_id})

            return res.status(201).json({
                success : true,
                New_Document : newDocument,
                message : "WorkSpace Document Created Successfully "
            })
        }else{
            return res.status(403).json({
                success : false,
                message : "WorkSpaces Is Not Owned By The User"
            })
        }

    }catch(e){
        console.error(e)
        return res.status(500).json({
                success : false,
                message : "Error is occuring"
            })
    }
})

// Fetch Document Route Handler
router.get('/getWorkspaceDocument/:workspace_id', isValidUser ,async(req,res) => {
    try{
        const workspace_id = req.params.workspace_id;
        const workspace = await WORKSPACE.findById(workspace_id);
        const owner_id = req.loginuser.id;

        if (!workspace) {
        return res.status(404).json({
        success: false,
        message: "Workspace not found",
        });
        }

        // if(workspace.owner_id.toString() == owner_id.toString()){

            const document = await DOCUMENT.find({workspace_id});
        
                return res.status(200).json({
                    success : true,
                    document : document,
                    message : "Documents Fetched Successfully"
                });
        // }else{
        //     return res.status(403).json({
        //         success: false,
        //         message: "You do not have access to this workspace",
        //         });
        // }
        

    }catch(e){
        console.error(e);
        return res.status(500).json({
            success : false,
            message : "Failed to fetch documents"
        });
    }
});

// Update Workspace Document Route Handler
router.put('/updateWorkspaceDocument/:document_id', isValidUser ,async(req,res) => {
    try{
        const document_id = req.params.document_id;
        const{content} = req.body;
        const document = await DOCUMENT.findById(document_id);
        const owner_id = req.loginuser.id;

        if (!document) {
            return res.status(404).json({
                success: false,
                message: "Document not found",
            });
            }
        
        const workspace = await WORKSPACE.findById(document.workspace_id);

        if (!workspace) {
            return res.status(404).json({
                success: false,
                message: "Workspace not found",
            });
            }

        if (typeof content !== "string") {
            return res.status(400).json({
                success: false,
                message: "Content must be a string",
            });
            }



        if(workspace.owner_id.toString() == owner_id.toString()){
            document.content = content;
            await document.save();
            return res.status(200).json({
                success : true,
                updatedDocument : document,
                message : "WorkSpace Document Updated Successfully "
            })
        }else{
            return res.status(403).json({
                success : false,
                message : "You do not have permission to modify this document"
            })
        }

    }catch(e){
        console.error(e)
        return res.status(500).json({
                success : false,
                message : "Error is occuring"
            })
    }
});


// DELETE DOCUMENT HANDLER
router.delete('/deleteWorkspaceDocument/:document_id', isValidUser, async(req,res) => {
    try{
        const document_id = req.params.document_id
        const owner_id = req.loginuser.id;

        const document = await DOCUMENT.findById(document_id);

        if (!document) {
            return res.status(404).json({
                success: false,
                message: "Document not found",
            });
            }
        
        const workspace = await WORKSPACE.findById(document.workspace_id);

        if (!workspace) {
            return res.status(404).json({
                success: false,
                message: "Workspace not found",
            });
            }

        if(workspace.owner_id.toString() == owner_id.toString()){
            await DOCUMENT.findByIdAndDelete(document_id);
            return res.status(200).json({
                success : true,
                message : "WorkSpace Document Deleted Successfully "
            })
        }else{
            return res.status(403).json({
                success : false,
                message : "You do not have permission to delete this document"
            })
        }

    }catch(e){
        console.error(e)
        return res.status(500).json({
                success : false,
                message : "Error is occuring"
            })
    }
    

}) 























// Code Execution Routes
// Javascript Code execution route
router.post("/execute", isValidUser, async(req,res) => {
    try{
        const {code, input} = req.body;

        if(!code || code === ""){
            return res.status(400).json({
                success : false,
                output : "Please write a code first"
            })
        }

        const fileName = `temp_${Date.now()}.js`;
        const filePath = path.join(__dirname,"temp",fileName);

        fs.writeFileSync(filePath, code);

        const child = spawn('node', [filePath]);

        let timedOut = false;
        const timer = setTimeout(() => {
            child.kill();
            timedOut = true;
        }, 5000);


        if (input) {
        child.stdin.write(input);
        }
        child.stdin.end();

        let output = "";
        let error = "";

        child.stdout.on('data', (data) => {
        output += data.toString();
        });

        child.stderr.on('data', (data) => {
        error += data.toString();
        });

        child.on('close', (exitcode) => {
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }// delete file

        clearTimeout(timer);
            if(timedOut){
                return res.status(200).json({
                success: false,
                output: "",
                error: "Execution timed out (5 seconds limit)"
            });
            }else{
            return res.status(200).json({
                success: error ? false : true,
                output : output,
                error : error
            });
            }
        });

    }catch(e){
        console.error(e)
        return res.status(500).json({
            success : false,
            output : "Unable to execute code"
            })
    }
});



module.exports = router;