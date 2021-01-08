import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../service/auth.service';
@Component({
  selector: 'app-services',
  templateUrl: './services.component.html',
  styleUrls: ['./services.component.css']
})
export class ServicesComponent implements OnInit {
 

  constructor(public authService: AuthService) {
   
  }

  ngOnInit(): void {
  }
  
 
}
