using CRMS.Data.DTOs.Auth;
using CRMS.Data.Models;
using CRMS.Repository.Interfaces;
using CRMS.Services.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace CRMS.Services.Imps;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly ITokenService _tokenService;
    private readonly IPasswordHasher<User> _passwordHasher;
    private readonly IWebsiteService _websiteService;

    public AuthService(IUserRepository userRepository, ITokenService tokenService, IPasswordHasher<User> passwordHasher, IWebsiteService websiteService)
    {
        _userRepository = userRepository;
        _tokenService = tokenService;
        _passwordHasher = passwordHasher;
        _websiteService = websiteService;
    }

    public async Task<LoginResponseDto?> LoginAsync(LoginRequestDto request)
    {
        var user = await _userRepository.GetByUsernameAsync(request.Username);
        if (user is null || !user.IsActive)
        {
            return null;
        }

        var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
        if (result == PasswordVerificationResult.Failed)
        {
            return null;
        }

        var (token, expiresAt) = _tokenService.GenerateToken(user);
        var websites = await _websiteService.GetAccessibleAsync(user.Id, user.Role == Role.Admin);

        return new LoginResponseDto
        {
            Token = token,
            ExpiresAt = expiresAt,
            Username = user.Username,
            Role = user.Role.ToString(),
            Websites = websites
        };
    }
}
