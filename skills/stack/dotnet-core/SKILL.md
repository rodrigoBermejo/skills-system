# .NET Core - Enterprise C# Backend Framework

**Scope:** backend  
**Trigger:** cuando se trabaje con C#, .NET, .NET Core, ASP.NET Core, APIs RESTful con C#, o desarrollo backend enterprise con .NET  
**Tools:** view, file_create, str_replace, bash_tool  
**Version:** 1.0.0  

---

## Proposito

Esta skill te guía para crear aplicaciones backend enterprise con .NET Core y C#. Cubre desde setup hasta arquitectura en capas, Entity Framework Core, ASP.NET Identity, testing con xUnit y deployment de aplicaciones robustas y escalables.

## Cuando Usar Esta Skill

- Crear APIs REST enterprise con C#
- Implementar arquitectura en capas (Controller-Service-Repository)
- Configurar Entity Framework Core con SQL Server
- Implementar autenticación y autorización con JWT
- Desarrollar microservicios con .NET
- Testing con xUnit y Moq
- Aplicaciones Windows/Azure enterprise

## Contexto y Conocimiento

### Versiones
- **.NET:** 8.0 LTS (recomendado) o 7.0
- **C#:** 12
- **ASP.NET Core:** 8.0
- **Entity Framework Core:** 8.0

### Setup de Proyecto

```bash
# Verificar instalación
dotnet --version

# Crear nuevo proyecto Web API
dotnet new webapi -n MyApp -o MyApp

# Navegar al proyecto
cd MyApp

# Agregar paquetes comunes
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
dotnet add package Swashbuckle.AspNetCore

# Ejecutar
dotnet run
```

### Estructura de Proyecto

```
MyApp/
├── Controllers/                  # API Controllers
│   ├── UsersController.cs
│   └── AuthController.cs
├── Services/                     # Business Logic
│   ├── IUserService.cs
│   ├── UserService.cs
│   └── IAuthService.cs
├── Repositories/                 # Data Access
│   ├── IUserRepository.cs
│   └── UserRepository.cs
├── Models/                       # Entities
│   ├── User.cs
│   └── Product.cs
├── DTOs/                         # Data Transfer Objects
│   ├── UserDto.cs
│   ├── LoginRequest.cs
│   └── RegisterRequest.cs
├── Data/                         # Database Context
│   └── ApplicationDbContext.cs
├── Middleware/                   # Custom Middleware
│   └── ExceptionMiddleware.cs
├── Configuration/                # Config classes
│   ├── JwtSettings.cs
│   └── DatabaseSettings.cs
├── Mappings/                     # AutoMapper Profiles
│   └── MappingProfile.cs
├── Program.cs                    # Entry point
├── appsettings.json             # Configuration
├── appsettings.Development.json
└── MyApp.csproj                 # Project file
```

## Flujo de Trabajo

### 1. Program.cs (Entry Point)

**.NET 8 con Minimal API style:**
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using MyApp.Data;
using MyApp.Services;
using MyApp.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Add services to container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Dependency Injection
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// AutoMapper
builder.Services.AddAutoMapper(typeof(Program));

// JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings["Issuer"],
            ValidAudience = jwtSettings["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtSettings["Secret"]!))
        };
    });

builder.Services.AddAuthorization();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                       .AllowAnyMethod()
                       .AllowAnyHeader());
});

var app = builder.Build();

// Configure HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### 2. Configuration (appsettings.json)

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyAppDb;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "JwtSettings": {
    "Secret": "YourSuperSecretKeyThatIsAtLeast32CharactersLong",
    "Issuer": "MyApp",
    "Audience": "MyAppUsers",
    "ExpirationInMinutes": 1440
  }
}
```

### 3. Entity (Model)

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyApp.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        public string PasswordHash { get; set; } = string.Empty;
        
        [Required]
        public UserRole Role { get; set; } = UserRole.User;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        public ICollection<Order>? Orders { get; set; }
    }
    
    public enum UserRole
    {
        User,
        Admin
    }
}
```

### 4. DbContext (Entity Framework Core)

```csharp
using Microsoft.EntityFrameworkCore;
using MyApp.Models;

namespace MyApp.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }
        
        public DbSet<User> Users { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Order> Orders { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // User configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.Property(e => e.Name).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Role).HasConversion<string>();
                
                // Relationships
                entity.HasMany(e => e.Orders)
                      .WithOne(o => o.User)
                      .HasForeignKey(o => o.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });
            
            // Seed data
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = 1,
                    Name = "Admin",
                    Email = "admin@example.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                    Role = UserRole.Admin,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                }
            );
        }
    }
}
```

### 5. DTOs (Data Transfer Objects)

```csharp
using System.ComponentModel.DataAnnotations;

namespace MyApp.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
    
    public class RegisterRequest
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(50, MinimumLength = 3)]
        public string Name { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Password is required")]
        [StringLength(100, MinimumLength = 6)]
        public string Password { get; set; } = string.Empty;
    }
    
    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        public string Password { get; set; } = string.Empty;
    }
    
    public class LoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public UserDto User { get; set; } = null!;
    }
}
```

### 6. Repository Pattern

```csharp
using MyApp.Models;

namespace MyApp.Repositories
{
    public interface IUserRepository
    {
        Task<IEnumerable<User>> GetAllAsync();
        Task<User?> GetByIdAsync(int id);
        Task<User?> GetByEmailAsync(string email);
        Task<User> CreateAsync(User user);
        Task<User> UpdateAsync(User user);
        Task<bool> DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);
        Task<bool> EmailExistsAsync(string email);
    }
}

// UserRepository.cs
using Microsoft.EntityFrameworkCore;
using MyApp.Data;
using MyApp.Models;

namespace MyApp.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly ApplicationDbContext _context;
        
        public UserRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        
        public async Task<IEnumerable<User>> GetAllAsync()
        {
            return await _context.Users.ToListAsync();
        }
        
        public async Task<User?> GetByIdAsync(int id)
        {
            return await _context.Users.FindAsync(id);
        }
        
        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);
        }
        
        public async Task<User> CreateAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return user;
        }
        
        public async Task<User> UpdateAsync(User user)
        {
            user.UpdatedAt = DateTime.UtcNow;
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return user;
        }
        
        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return false;
            
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }
        
        public async Task<bool> ExistsAsync(int id)
        {
            return await _context.Users.AnyAsync(u => u.Id == id);
        }
        
        public async Task<bool> EmailExistsAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }
    }
}
```

### 7. Service Layer

```csharp
using MyApp.DTOs;

namespace MyApp.Services
{
    public interface IUserService
    {
        Task<IEnumerable<UserDto>> GetAllUsersAsync();
        Task<UserDto> GetUserByIdAsync(int id);
        Task<UserDto> CreateUserAsync(RegisterRequest request);
        Task<UserDto> UpdateUserAsync(int id, UserDto userDto);
        Task<bool> DeleteUserAsync(int id);
    }
}

// UserService.cs
using AutoMapper;
using MyApp.DTOs;
using MyApp.Models;
using MyApp.Repositories;

namespace MyApp.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IMapper _mapper;
        private readonly ILogger<UserService> _logger;
        
        public UserService(
            IUserRepository userRepository,
            IMapper mapper,
            ILogger<UserService> logger)
        {
            _userRepository = userRepository;
            _mapper = mapper;
            _logger = logger;
        }
        
        public async Task<IEnumerable<UserDto>> GetAllUsersAsync()
        {
            _logger.LogInformation("Fetching all users");
            var users = await _userRepository.GetAllAsync();
            return _mapper.Map<IEnumerable<UserDto>>(users);
        }
        
        public async Task<UserDto> GetUserByIdAsync(int id)
        {
            _logger.LogInformation("Fetching user with id: {Id}", id);
            var user = await _userRepository.GetByIdAsync(id);
            
            if (user == null)
                throw new KeyNotFoundException($"User not found with id: {id}");
            
            return _mapper.Map<UserDto>(user);
        }
        
        public async Task<UserDto> CreateUserAsync(RegisterRequest request)
        {
            _logger.LogInformation("Creating user with email: {Email}", request.Email);
            
            if (await _userRepository.EmailExistsAsync(request.Email))
                throw new InvalidOperationException("Email already exists");
            
            var user = new User
            {
                Name = request.Name,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Role = UserRole.User,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            
            var createdUser = await _userRepository.CreateAsync(user);
            _logger.LogInformation("User created with id: {Id}", createdUser.Id);
            
            return _mapper.Map<UserDto>(createdUser);
        }
        
        public async Task<UserDto> UpdateUserAsync(int id, UserDto userDto)
        {
            _logger.LogInformation("Updating user with id: {Id}", id);
            
            var user = await _userRepository.GetByIdAsync(id);
            if (user == null)
                throw new KeyNotFoundException($"User not found with id: {id}");
            
            user.Name = userDto.Name;
            user.Email = userDto.Email;
            
            var updatedUser = await _userRepository.UpdateAsync(user);
            _logger.LogInformation("User updated: {Id}", id);
            
            return _mapper.Map<UserDto>(updatedUser);
        }
        
        public async Task<bool> DeleteUserAsync(int id)
        {
            _logger.LogInformation("Deleting user with id: {Id}", id);
            
            if (!await _userRepository.ExistsAsync(id))
                throw new KeyNotFoundException($"User not found with id: {id}");
            
            await _userRepository.DeleteAsync(id);
            _logger.LogInformation("User deleted: {Id}", id);
            
            return true;
        }
    }
}
```

### 8. Controller (REST API)

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyApp.DTOs;
using MyApp.Services;

namespace MyApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ILogger<UsersController> _logger;
        
        public UsersController(
            IUserService userService,
            ILogger<UsersController> logger)
        {
            _userService = userService;
            _logger = logger;
        }
        
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetAllUsers()
        {
            try
            {
                var users = await _userService.GetAllUsersAsync();
                return Ok(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching users");
                return StatusCode(500, "An error occurred while fetching users");
            }
        }
        
        [HttpGet("{id}")]
        public async Task<ActionResult<UserDto>> GetUser(int id)
        {
            try
            {
                var user = await _userService.GetUserByIdAsync(id);
                return Ok(user);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching user {Id}", id);
                return StatusCode(500, "An error occurred");
            }
        }
        
        [HttpPost]
        [AllowAnonymous]
        public async Task<ActionResult<UserDto>> CreateUser([FromBody] RegisterRequest request)
        {
            try
            {
                var user = await _userService.CreateUserAsync(request);
                return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user");
                return StatusCode(500, "An error occurred");
            }
        }
        
        [HttpPut("{id}")]
        public async Task<ActionResult<UserDto>> UpdateUser(int id, [FromBody] UserDto userDto)
        {
            try
            {
                var user = await _userService.UpdateUserAsync(id, userDto);
                return Ok(user);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user {Id}", id);
                return StatusCode(500, "An error occurred");
            }
        }
        
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            try
            {
                await _userService.DeleteUserAsync(id);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user {Id}", id);
                return StatusCode(500, "An error occurred");
            }
        }
    }
}
```

### 9. AutoMapper Profile

```csharp
using AutoMapper;
using MyApp.DTOs;
using MyApp.Models;

namespace MyApp.Mappings
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<User, UserDto>()
                .ForMember(dest => dest.Role, 
                           opt => opt.MapFrom(src => src.Role.ToString()));
            
            CreateMap<UserDto, User>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore());
            
            CreateMap<RegisterRequest, User>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.Role, opt => opt.MapFrom(src => UserRole.User));
        }
    }
}
```

### 10. Migrations

```bash
# Crear primera migración
dotnet ef migrations add InitialCreate

# Aplicar migración
dotnet ef database update

# Revertir migración
dotnet ef database update PreviousMigrationName

# Remover última migración
dotnet ef migrations remove
```

## Testing con xUnit y Moq

```csharp
using Moq;
using Xunit;
using AutoMapper;
using Microsoft.Extensions.Logging;
using MyApp.Services;
using MyApp.Repositories;
using MyApp.DTOs;
using MyApp.Models;

namespace MyApp.Tests.Services
{
    public class UserServiceTests
    {
        private readonly Mock<IUserRepository> _mockRepository;
        private readonly Mock<IMapper> _mockMapper;
        private readonly Mock<ILogger<UserService>> _mockLogger;
        private readonly UserService _userService;
        
        public UserServiceTests()
        {
            _mockRepository = new Mock<IUserRepository>();
            _mockMapper = new Mock<IMapper>();
            _mockLogger = new Mock<ILogger<UserService>>();
            _userService = new UserService(
                _mockRepository.Object,
                _mockMapper.Object,
                _mockLogger.Object);
        }
        
        [Fact]
        public async Task GetAllUsersAsync_ReturnsListOfUsers()
        {
            // Arrange
            var users = new List<User>
            {
                new User { Id = 1, Name = "John", Email = "john@test.com" }
            };
            var userDtos = new List<UserDto>
            {
                new UserDto { Id = 1, Name = "John", Email = "john@test.com" }
            };
            
            _mockRepository.Setup(r => r.GetAllAsync())
                .ReturnsAsync(users);
            _mockMapper.Setup(m => m.Map<IEnumerable<UserDto>>(users))
                .Returns(userDtos);
            
            // Act
            var result = await _userService.GetAllUsersAsync();
            
            // Assert
            Assert.NotNull(result);
            Assert.Single(result);
            Assert.Equal("John", result.First().Name);
        }
        
        [Fact]
        public async Task GetUserByIdAsync_UserExists_ReturnsUser()
        {
            // Arrange
            var user = new User { Id = 1, Name = "John", Email = "john@test.com" };
            var userDto = new UserDto { Id = 1, Name = "John", Email = "john@test.com" };
            
            _mockRepository.Setup(r => r.GetByIdAsync(1))
                .ReturnsAsync(user);
            _mockMapper.Setup(m => m.Map<UserDto>(user))
                .Returns(userDto);
            
            // Act
            var result = await _userService.GetUserByIdAsync(1);
            
            // Assert
            Assert.NotNull(result);
            Assert.Equal(1, result.Id);
            Assert.Equal("John", result.Name);
        }
        
        [Fact]
        public async Task GetUserByIdAsync_UserNotExists_ThrowsKeyNotFoundException()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999))
                .ReturnsAsync((User?)null);
            
            // Act & Assert
            await Assert.ThrowsAsync<KeyNotFoundException>(
                () => _userService.GetUserByIdAsync(999));
        }
        
        [Fact]
        public async Task DeleteUserAsync_UserExists_ReturnsTrue()
        {
            // Arrange
            _mockRepository.Setup(r => r.ExistsAsync(1))
                .ReturnsAsync(true);
            _mockRepository.Setup(r => r.DeleteAsync(1))
                .ReturnsAsync(true);
            
            // Act
            var result = await _userService.DeleteUserAsync(1);
            
            // Assert
            Assert.True(result);
            _mockRepository.Verify(r => r.DeleteAsync(1), Times.Once);
        }
    }
}
```

## Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Circular dependency | DbContext en service | Usar Repository pattern |
| Null reference | Navigation properties no cargadas | Usar .Include() o lazy loading |
| Migration failed | Modelo inconsistente con BD | Verificar OnModelCreating |
| JWT validation failed | Secret key incorrecta | Verificar appsettings.json |
| CORS error | CORS policy no configurada | Agregar UseCors en Program.cs |

## Checklist de Validacion

- [ ] Arquitectura en capas (Controller-Service-Repository)
- [ ] DTOs para requests/responses
- [ ] AutoMapper configurado
- [ ] Entity Framework migrations
- [ ] Dependency Injection registrado
- [ ] JWT authentication implementado
- [ ] Logging con ILogger
- [ ] Exception handling
- [ ] Unit tests (>70% coverage)
- [ ] Configuration por environment

## Best Practices

1. **Dependency Injection** - Usar interfaces siempre
2. **Async/Await** - Todos los métodos I/O async
3. **Repository Pattern** - Separar data access
4. **DTOs** - Nunca exponer entities directamente
5. **AutoMapper** - Para mapeo entre entities y DTOs
6. **Logging** - ILogger en servicios y controllers
7. **Configuration** - appsettings.json por environment
8. **Testing** - xUnit + Moq para unit tests
9. **Security** - JWT con roles y policies
10. **Validation** - Data Annotations + FluentValidation

---

**Última actualización:** Fase 4 - Skills Backend Robusto  
**Mantenedor:** Sistema de Skills  
**Siguiente:** Complementar con SQL databases para persistencia robusta
