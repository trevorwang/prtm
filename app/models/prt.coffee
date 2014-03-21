# load the things we need
mongoose = require "mongoose"

# define the schema for our user model
PrtSchema = mongoose.Schema
prtSchema = new PrtSchema
  email_id: String
  sender:
    name: String
    email: String
  subject: String
  conversation_id: String
  conversation_index: String
  conversation_topic: String
  body: String
  body_type: String
  categories: Array
  change_key: String
  to_recipients: Array
  attachments: Array

module.exports = mongoose.model "prts", prtSchema
