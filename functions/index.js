const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');
 
//Initializing Firebase Admin SDK
admin.initializeApp();
 
//Creating Nodemailer transporter using your Mailtrap SMTP details
let transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'abhaysinghal00@gmail.com',
      pass: 'manumanu00'
    }
});
 
//Creating a Firebase Cloud Function
exports.emailSender = functions.https.onRequest((req, res) => {   
      
            //Defining mailOptions
            const mailOptions = {
            from: 'abhaysinghal00@gmail.com', //Adding sender's email
            to: 'tastebuds.udaipur@gmail.com', //Getting recipient's email by query string
            subject: 'Email Sent via Firebase', //Email subject
            html: '<b>Sending emails with Firebase is easy!</b>' //Email content in HTML
        };
  
        //Returning result
        return transporter.sendMail(mailOptions, (err, info) => {
            if(err){
                return res.send(err.toString());
            }
            return res.send('Email sent succesfully');
        });
       
});
