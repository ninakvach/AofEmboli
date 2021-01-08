import { Component, OnInit } from '@angular/core';
export class Test { googleUser: gapi.auth2.GoogleUser }
import { AngularFireAuth } from "@angular/fire/auth";
import { Router } from "@angular/router";
import { AuthService } from '../../service/auth.service';
@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {
  email: string;
  password: string;
  vr: boolean;

  constructor(public authService: AuthService) {
   
  }


  signup() {
    this.authService.signup(this.email, this.password);
    this.email = this.password = '';
   
  }

  login() {
  
    this.authService.login(this.email, this.password);
    this.email = this.password = '';       
  }

  logout() {
    this.authService.logout();
  }
  reset(){
    this.authService.resetPassword(this.email);
  }
 
    
 

  
}
