import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './components/home/home.component';
import { IntroComponent } from './components/intro/intro.component';
import { DescriptionComponent } from './components/description/description.component';
import { ServicesComponent } from './components/services/services.component';
import { DetailsComponent } from './components/details/details.component';
import { Details2Component } from './components/details2/details2.component';
import { TestimonialsComponent } from './components/testimonials/testimonials.component';
import { CallmeComponent } from './components/callme/callme.component';
import { ProjectsComponent } from './components/projects/projects.component';
import { TeamsComponent } from './components/teams/teams.component';
import { AboutComponent } from './components/about/about.component';
import { ContactComponent } from './components/contact/contact.component';
import { FooterComponent } from './components/footer/footer.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    IntroComponent,
    DescriptionComponent,
    ServicesComponent,
    DetailsComponent,
    Details2Component,
    TestimonialsComponent,
    CallmeComponent,
    ProjectsComponent,
    TeamsComponent,
    AboutComponent,
    ContactComponent,
    FooterComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
