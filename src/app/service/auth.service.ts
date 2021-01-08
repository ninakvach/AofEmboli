// auth.service.ts
import { Injectable } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/auth';
import { Observable } from 'rxjs';
import swal from 'sweetalert';
import * as firebase from 'firebase/app';
@Injectable({
  providedIn: 'root'
})

export class AuthService {
  
  user: Observable<firebase.default.User>;
  verify: Boolean;
  role: string;
  constructor(private firebaseAuth: AngularFireAuth) {
    this.user = firebaseAuth.authState;
    
  }

  ngOnInit(){
    this.role = this.readLocalStorageValue("verify");
}
readLocalStorageValue(key: string): string {
  return localStorage.getItem(key);
}
  signup(email: string, password: string) {
    this.firebaseAuth
      .createUserWithEmailAndPassword(email, password)
      .then(
        value => {
          console.log('Success!', value);
        this.SendVerificationMail();
     
        swal("Verify Email To Download Project!","And Login Again","warning");
      }
      )
      .catch(err => {
        swal({
          text: err.message,
        });
        console.log('Something went wrong:',err.message);
      });
      
  }

  login(email: string, password: string) {
    this.firebaseAuth
      .signInWithEmailAndPassword(email, password)
      .then(value => {
        console.log('Nice, it worked!');
        console.log(value.user.emailVerified);
        this.verify = value.user.emailVerified;
        if(value.user.emailVerified){
         
        localStorage.setItem("verify", "true");
        }
      })
      .catch(err => {
        swal({
          text: err.message,
        });
        console.log('Something went wrong:',err.message);
      });
  }

  logout() {
    this.firebaseAuth.signOut();
    localStorage.setItem("verify", "false");
  }
  async SendVerificationMail() {
    (await this.firebaseAuth.currentUser).sendEmailVerification().then(() => {
        console.log('email sent');
    });
}

resetPassword(email: string): Promise<void>{
  return this.firebaseAuth.sendPasswordResetEmail(email) .then(value => {
    console.log('Nice, it worked!');
    swal({
      text: "New Password is Sent By Email",
    });
    
  }) .catch(err => {
  
      swal({
        text: "Enter just Email and after press Reset Password !",
      });
    console.log('Something went wrong:',err.message);
  });
}


async ver() {

(await this.firebaseAuth.currentUser).emailVerified;
 return new Promise((resolve, reject) => { resolve(true); })
}


}