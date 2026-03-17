const mongoose = require('mongoose');

const documentModel = new mongoose.Schema({
    name : {
            type : String,
            required : true,
        },
    workspace_id : {
            type: mongoose.Schema.Types.ObjectId,
            ref: "WorkspaceModel",
            required: true,
        },
    content : {
            type : String,
            // required : true,
            default : ""
    },
    },
        { timestamps: true } // this automatically adds createAt and updatedAt and also updates the updatedAt value with every update
)

module.exports = mongoose.model("DocumentModel", documentModel)