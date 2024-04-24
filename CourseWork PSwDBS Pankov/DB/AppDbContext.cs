using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace CourseWork_PSwDBS_Pankov.DB
{
    internal class AppDbContext : DbContext
    {
        public DbSet<City> cities { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                string Server = "localhost";
                string Port = "5432";
                string DataBase = "TransportCargo_to_MTC";
                string User = "postgres";
                string Password = "1234";

                string connectionString = $"Server={Server};Port={Port};Database={DataBase};User Id={User};Password={Password};";

                optionsBuilder.UseNpgsql(connectionString);
            }
        }
    }
}
