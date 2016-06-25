using CarsRental.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CarsRental.Controllers
{
    public class HomeController : Controller
    {
        // GET: Home
        public ActionResult Index()
        {
            // testy gita
            return View();
        }
        public ActionResult Login()
        {
            // testy gita
            return View();
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(CarsRental.Models.RentalUsers u)
        {
            if (ModelState.IsValid)
            {
                using(RentalDBEntities db = new RentalDBEntities())
                {
                    var v = db.RentalUsers.Where(a => a.login.Equals(u.login) && a.password.Equals(u.password)).FirstOrDefault();
                    if(v != null)
                    {
                        Session["UserID"] = v.userID.ToString();
                        Session["Username"] = v.login.ToString();
                        return RedirectToAction("Admin");
                    }
                }
            }
            return View(u);
        }
        public ActionResult Admin()
        {
            return View();
        }
    }
}