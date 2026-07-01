using CRMS.Data.DTOs.Users;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace CRMS.Services.Imps;

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher<User> _passwordHasher;

    public UserService(IUserRepository userRepository, IPasswordHasher<User> passwordHasher)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<List<UserDto>> GetAllAsync()
    {
        var users = await _userRepository.GetAllAsync();
        return users.Select(ToDto).ToList();
    }

    public async Task<bool> UsernameExistsAsync(string username) =>
        await _userRepository.ExistsByUsernameAsync(username);

    public async Task<UserDto> CreateAsync(CreateUserDto request)
    {
        if (await _userRepository.ExistsByUsernameAsync(request.Username))
        {
            throw new InvalidOperationException("Username already exists.");
        }

        var user = new User
        {
            Username = request.Username,
            Role = request.Role
        };
        user.PasswordHash = _passwordHasher.HashPassword(user, request.Password);

        await _userRepository.AddAsync(user);

        return ToDto(user);
    }

    public async Task<UserDto?> UpdateAsync(int id, UpdateUserDto request)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user is null)
        {
            return null;
        }

        if (await _userRepository.ExistsByUsernameAsync(request.Username, excludingId: id))
        {
            throw new InvalidOperationException("Username already exists.");
        }

        user.Username = request.Username;
        user.Role = request.Role;
        user.NotifyOnNewCase = request.NotifyOnNewCase;
        await _userRepository.SaveChangesAsync();

        return ToDto(user);
    }

    public async Task<bool> ResetPasswordAsync(int id, ResetPasswordDto request)
    {
        var user = await _userRepository.GetByIdAsync(id);
        if (user is null)
        {
            return false;
        }

        user.PasswordHash = _passwordHasher.HashPassword(user, request.NewPassword);
        await _userRepository.SaveChangesAsync();

        return true;
    }

    public async Task<bool> SetActiveAsync(int id, bool isActive, int currentUserId)
    {
        if (id == currentUserId && !isActive)
        {
            throw new InvalidOperationException("You cannot disable your own account.");
        }

        var user = await _userRepository.GetByIdAsync(id);
        if (user is null)
        {
            return false;
        }

        user.IsActive = isActive;
        await _userRepository.SaveChangesAsync();

        return true;
    }

    private static UserDto ToDto(User user) => new()
    {
        Id = user.Id,
        Username = user.Username,
        Role = user.Role.ToString(),
        IsActive = user.IsActive,
        NotifyOnNewCase = user.NotifyOnNewCase,
        CreatedAt = user.CreatedAt
    };
}
