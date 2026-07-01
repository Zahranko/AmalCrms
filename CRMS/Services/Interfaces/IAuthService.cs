using CRMS.Data.DTOs.Auth;

namespace CRMS.Services.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto?> LoginAsync(LoginRequestDto request);
}
