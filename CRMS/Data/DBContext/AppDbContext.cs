using CRMS.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Data.DBContext;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Department> Departments => Set<Department>();
    public DbSet<Doctor> Doctors => Set<Doctor>();
    public DbSet<ReferralSource> ReferralSources => Set<ReferralSource>();
    public DbSet<Procedure> Procedures => Set<Procedure>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<CaseAction> CaseActions => Set<CaseAction>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(u => u.Username).IsUnique();
            entity.Property(u => u.Username).HasMaxLength(50).IsRequired();
            entity.Property(u => u.PasswordHash).IsRequired();
            entity.Property(u => u.Role).HasConversion<string>().HasMaxLength(20).IsRequired();
            entity.Property(u => u.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.Property(d => d.Name).HasMaxLength(100).IsRequired();
            entity.Property(d => d.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<ReferralSource>(entity =>
        {
            entity.Property(r => r.Name).HasMaxLength(100).IsRequired();
            entity.Property(r => r.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<Procedure>(entity =>
        {
            entity.Property(p => p.Name).HasMaxLength(100).IsRequired();
            entity.Property(p => p.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<Doctor>(entity =>
        {
            entity.Property(d => d.Name).HasMaxLength(100).IsRequired();
            entity.Property(d => d.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<Customer>(entity =>
        {
            entity.Property(c => c.Name).HasMaxLength(100).IsRequired();
            entity.Property(c => c.PhoneCountryCode).HasMaxLength(10).IsRequired();
            entity.Property(c => c.PhoneNumber).HasMaxLength(20).IsRequired();
            entity.Property(c => c.Description).HasMaxLength(2000).IsRequired();
            entity.Property(c => c.Status).HasConversion<string>().HasMaxLength(20).IsRequired();

            entity.HasOne(c => c.ReferralSource).WithMany().HasForeignKey(c => c.ReferralSourceId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.Procedure).WithMany().HasForeignKey(c => c.ProcedureId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.Department).WithMany().HasForeignKey(c => c.DepartmentId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.Doctor).WithMany().HasForeignKey(c => c.DoctorId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.CreatedBy).WithMany().HasForeignKey(c => c.CreatedByUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.AssignedTo).WithMany().HasForeignKey(c => c.AssignedToUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.ForwardedBy).WithMany().HasForeignKey(c => c.ForwardedByUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(c => c.PendingForwardTo).WithMany().HasForeignKey(c => c.PendingForwardToUserId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<CaseAction>(entity =>
        {
            entity.Property(a => a.Type).HasConversion<string>().HasMaxLength(30).IsRequired();
            entity.Property(a => a.ResultingStatus).HasConversion<string>().HasMaxLength(20);
            entity.Property(a => a.Note).HasMaxLength(2000);

            entity.HasOne(a => a.Customer).WithMany().HasForeignKey(a => a.CustomerId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(a => a.Actor).WithMany().HasForeignKey(a => a.ActorUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(a => a.Target).WithMany().HasForeignKey(a => a.TargetUserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(a => a.Department).WithMany().HasForeignKey(a => a.DepartmentId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(a => a.Doctor).WithMany().HasForeignKey(a => a.DoctorId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.Property(n => n.Message).HasMaxLength(500).IsRequired();
            entity.Property(n => n.Type).HasConversion<string>().HasMaxLength(30).IsRequired();

            entity.HasOne(n => n.User).WithMany().HasForeignKey(n => n.UserId).OnDelete(DeleteBehavior.Restrict);
            entity.HasOne(n => n.Customer).WithMany().HasForeignKey(n => n.CustomerId).OnDelete(DeleteBehavior.Restrict);
        });
    }
}
