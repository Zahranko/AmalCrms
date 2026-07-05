using CRMS.Data.Models;
using CRMS.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CRMS.Data.DBContext;

public class AppDbContext : DbContext
{
    private readonly IWebsiteContext _websiteContext;

    public AppDbContext(DbContextOptions<AppDbContext> options, IWebsiteContext websiteContext) : base(options)
    {
        _websiteContext = websiteContext;
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Website> Websites => Set<Website>();
    public DbSet<UserWebsite> UserWebsites => Set<UserWebsite>();
    public DbSet<WebsiteSetting> WebsiteSettings => Set<WebsiteSetting>();
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

        modelBuilder.Entity<Website>(entity =>
        {
            entity.HasIndex(w => w.Key).IsUnique();
            entity.Property(w => w.Key).HasMaxLength(50).IsRequired();
            entity.Property(w => w.NameEn).HasMaxLength(100).IsRequired();
            entity.Property(w => w.NameAr).HasMaxLength(100).IsRequired();
            entity.Property(w => w.IsActive).HasDefaultValue(true).IsRequired();
        });

        modelBuilder.Entity<UserWebsite>(entity =>
        {
            entity.HasKey(uw => new { uw.UserId, uw.WebsiteId });
            entity.HasOne(uw => uw.User).WithMany().HasForeignKey(uw => uw.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(uw => uw.Website).WithMany().HasForeignKey(uw => uw.WebsiteId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<WebsiteSetting>(entity =>
        {
            entity.HasIndex(s => new { s.WebsiteId, s.Key }).IsUnique();
            entity.Property(s => s.Key).HasMaxLength(100).IsRequired();
            entity.Property(s => s.Value).HasMaxLength(2000).IsRequired();
            // WebsiteId FK + query filter come from ConfigureTenant<WebsiteSetting> below.
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

        // Website (tenant) FK + global query filter for every ITenantScoped entity.
        // The filter reads _websiteContext.WebsiteId per query; when it is null
        // (no active website resolved) the comparison matches no rows — the safe
        // default that never leaks another website's data.
        ConfigureTenant<Department>(modelBuilder);
        ConfigureTenant<ReferralSource>(modelBuilder);
        ConfigureTenant<Procedure>(modelBuilder);
        ConfigureTenant<Doctor>(modelBuilder);
        ConfigureTenant<Customer>(modelBuilder);
        ConfigureTenant<Notification>(modelBuilder);
        ConfigureTenant<WebsiteSetting>(modelBuilder);
    }

    private void ConfigureTenant<TEntity>(ModelBuilder modelBuilder) where TEntity : class, ITenantScoped
    {
        modelBuilder.Entity<TEntity>(entity =>
        {
            entity.HasIndex(e => e.WebsiteId);
            entity.HasOne<Website>().WithMany().HasForeignKey(e => e.WebsiteId).OnDelete(DeleteBehavior.Restrict);
            entity.HasQueryFilter(e => e.WebsiteId == _websiteContext.WebsiteId);
        });
    }

    public override int SaveChanges()
    {
        StampWebsite();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        StampWebsite();
        return base.SaveChangesAsync(cancellationToken);
    }

    // Stamp the active website on new tenant rows so services/repositories never
    // set WebsiteId by hand. A tenant insert with no active website is a bug —
    // fail loudly rather than writing an orphan row.
    private void StampWebsite()
    {
        var newTenantEntries = ChangeTracker.Entries<ITenantScoped>()
            .Where(e => e.State == EntityState.Added && e.Entity.WebsiteId == 0)
            .ToList();

        if (newTenantEntries.Count == 0) return;

        if (_websiteContext.WebsiteId is not int websiteId)
            throw new InvalidOperationException("Cannot save website-scoped data without an active website context.");

        foreach (var entry in newTenantEntries)
            entry.Entity.WebsiteId = websiteId;
    }
}
