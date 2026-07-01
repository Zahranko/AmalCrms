using CRMS.Data.DTOs.Users;

namespace CRMS.Services.Interfaces;

public interface IUserService
{
    Task<List<UserDto>> GetAllAsync();
    Task<UserDto> CreateAsync(CreateUserDto request);
    Task<bool> UsernameExistsAsync(string username);
    Task<UserDto?> UpdateAsync(int id, UpdateUserDto request);
    Task<bool> ResetPasswordAsync(int id, ResetPasswordDto request);
    Task<bool> SetActiveAsync(int id, bool isActive, int currentUserId);
}
