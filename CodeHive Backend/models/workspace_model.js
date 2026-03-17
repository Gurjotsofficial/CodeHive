const mongoose = require('mongoose');

const workspace_model = new mongoose.Schema({
    name : {
        type : String,
        required : true,
    },
    owner_id : {
        type: mongoose.Schema.Types.ObjectId,
        ref: "UserSchema",
        required: true,
    },
    createdAt: {
        type : Date,
        required : true,
        default : Date.now()
    }
})

module.exports = mongoose.model("WorkspaceModel", workspace_model);