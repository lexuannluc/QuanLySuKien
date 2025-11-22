IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'QuanLySuKien')
BEGIN
    CREATE DATABASE QuanLySuKien;
END
GO

USE QuanLySuKien;
GO

CREATE TABLE DiaDiem (
    MaDiaDiem INT PRIMARY KEY IDENTITY(1,1),
    TenDiaDiem NVARCHAR(50) NOT NULL UNIQUE,
    DiaChi NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE NhaToChuc (
    MaNhaToChuc INT PRIMARY KEY IDENTITY(1,1),
    TenNhaToChuc NVARCHAR(50) NOT NULL,
    DiaChi NVARCHAR(100) NOT NULL,
    SoDienThoai VARCHAR(12) NOT NULL UNIQUE CHECK (LEN(SoDienThoai) >= 10)
);
GO

CREATE TABLE KhachMoi (
    MaKhachMoi INT PRIMARY KEY IDENTITY(1,1),
    TenKhachMoi NVARCHAR(50) NOT NULL,
    SoDienThoai VARCHAR(12) NOT NULL UNIQUE CHECK (LEN(SoDienThoai) >= 10),
    Email NVARCHAR(255) NOT NULL UNIQUE CHECK (Email LIKE '%@%')
);
GO

CREATE TABLE SuKien (
    MaSuKien INT PRIMARY KEY IDENTITY(1,1),
    TenSuKien NVARCHAR(50) NOT NULL,
    NgayToChuc DATE NOT NULL,
    MaDiaDiem INT NOT NULL,
    MaNhaToChuc INT NOT NULL,
    
    CONSTRAINT FK_SuKien_DiaDiem FOREIGN KEY (MaDiaDiem) REFERENCES DiaDiem(MaDiaDiem),
    CONSTRAINT FK_SuKien_NhaToChuc FOREIGN KEY (MaNhaToChuc) REFERENCES NhaToChuc(MaNhaToChuc)
);
GO

CREATE TABLE DangKy (
    MaDangKy INT PRIMARY KEY IDENTITY(1,1),
    NgayDangKy DATE NOT NULL DEFAULT GETDATE(),
    MaKhachMoi INT NOT NULL,
    MaSuKien INT NOT NULL,
    TinhTrang NVARCHAR(50) NOT NULL DEFAULT N'Chờ xác nhận',
    
    CONSTRAINT FK_DangKy_KhachMoi FOREIGN KEY (MaKhachMoi) REFERENCES KhachMoi(MaKhachMoi),
    CONSTRAINT FK_DangKy_SuKien FOREIGN KEY (MaSuKien) REFERENCES SuKien(MaSuKien),
    
    CHECK (TinhTrang IN (N'Chờ xác nhận', N'Đã xác nhận', N'Đã hủy'))
);
GO

INSERT INTO DiaDiem (TenDiaDiem, DiaChi)
VALUES
(N'Trung tâm Hội nghị Quốc gia', N'Mễ Trì, Nam Từ Liêm, Hà Nội'),
(N'Khách sạn Grand Plaza', N'117 Trần Duy Hưng, Cầu Giấy, Hà Nội'),
(N'Nhà hát Lớn Hà Nội', N'01 Tràng Tiền, Hoàn Kiếm, Hà Nội'),
(N'Trung tâm Triển lãm SECC', N'799 Nguyễn Văn Linh, Q7, TP.HCM'),
(N'Khách sạn Sheraton Sài Gòn', N'88 Đồng Khởi, Q1, TP.HCM');
GO

INSERT INTO NhaToChuc (TenNhaToChuc, DiaChi, SoDienThoai)
VALUES
(N'Công ty Sự kiện ABC', N'123 Lê Lợi, Q1, TP.HCM', '0901234567'),
(N'Tổ chức Sự kiện XYZ', N'456 Hai Bà Trưng, Hà Nội', '0912345678'),
(N'VNEvents', N'789 Nguyễn Trãi, Q5, TP.HCM', '0987654321'),
(N'Hanoi Event Planners', N'321 Kim Mã, Ba Đình, Hà Nội', '0978123456'),
(N'SaiGon Events', N'101 Pasteur, Q3, TP.HCM', '0909888777');
GO

INSERT INTO KhachMoi (TenKhachMoi, SoDienThoai, Email)
VALUES
(N'Nguyễn Văn An', '0912345678', 'an.nguyen@example.com'),
(N'Trần Thị Bích', '0988765432', 'bich.tran@gmail.com'),
(N'Lê Văn Cường', '0903111222', 'cuong.le@company.vn'),
(N'Phạm Thị Dung', '0945333444', 'dung.pham@email.com'),
(N'Hoàng Văn Em', '0966555777', 'em.hoang@domain.net');
GO

INSERT INTO SuKien (TenSuKien, NgayToChuc, MaDiaDiem, MaNhaToChuc)
VALUES
(N'Hội nghị AI Việt Nam 2025', '2025-10-20', 1, 1),
(N'Triển lãm Công nghệ TechExpo', '2025-11-15', 4, 3),
(N'Hòa nhạc Mùa Thu', '2025-09-05', 3, 2),
(N'Workshop Digital Marketing', '2025-10-10', 2, 4),
(N'Gala Dinner Doanh nhân Sài Gòn', '2025-12-01', 5, 5);
GO

INSERT INTO DangKy (MaKhachMoi, MaSuKien)
VALUES
(1, 1);

INSERT INTO DangKy (MaKhachMoi, MaSuKien, TinhTrang)
VALUES
(2, 1, N'Đã xác nhận');

INSERT INTO DangKy (MaKhachMoi, MaSuKien, NgayDangKy, TinhTrang)
VALUES
(3, 2, '2025-10-01', N'Đã xác nhận');

INSERT INTO DangKy (MaKhachMoi, MaSuKien, NgayDangKy, TinhTrang)
VALUES
(4, 3, '2025-08-15', N'Đã hủy');

INSERT INTO DangKy (MaKhachMoi, MaSuKien, TinhTrang)
VALUES
(5, 5, N'Đã xác nhận');
GO

alter authorization on database :: [QuanLySuKien] to [sa];

CREATE NONCLUSTERED INDEX IX_DangKy_KhachMoi_SuKien
ON DangKy (MaKhachMoi, MaSuKien);
GO

CREATE VIEW v_ChiTietDangKy
AS
SELECT 
    dk.MaDangKy,
    km.TenKhachMoi,
    km.Email,
    sk.TenSuKien,
    sk.NgayToChuc,
    dk.NgayDangKy,
    dk.TinhTrang
FROM 
    DangKy dk
JOIN 
    KhachMoi km ON dk.MaKhachMoi = km.MaKhachMoi
JOIN 
    SuKien sk ON dk.MaSuKien = sk.MaSuKien;
GO

CREATE PROCEDURE sp_ThemDangKyMoi
    @MaKhachMoi INT,
    @MaSuKien INT,
    @TinhTrang NVARCHAR(50) = N'Chờ xác nhận'
AS
BEGIN
    INSERT INTO DangKy (MaKhachMoi, MaSuKien, TinhTrang)
    VALUES (@MaKhachMoi, @MaSuKien, @TinhTrang);
END;
GO

exec dbo.sp_ThemDangKyMoi @MaKhachMoi = 1 , @MaSuKien = 2;

CREATE FUNCTION fn_DemSoNguoiDaXacNhan
(
    @MaSuKien INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;
    
    SELECT @SoLuong = COUNT(*)
    FROM DangKy
    WHERE MaSuKien = @MaSuKien AND TinhTrang = N'Đã xác nhận';
    
    RETURN @SoLuong;
END;
GO
select MaKhachMoi,MaSuKien,dbo.fn_DemSoNguoiDaXacNhan(MaSuKien) as SoNguoiDangKyChoTungSK from DangKy where TinhTrang = N'Đã xác nhận';

CREATE TRIGGER tr_KiemTraDangKyTrung
ON DangKy
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @MaKhachMoi INT;
    DECLARE @MaSuKien INT;
    DECLARE @TinhTrang NVARCHAR(50);
    DECLARE @NgayDangKy DATE;

    SELECT 
        @MaKhachMoi = i.MaKhachMoi,
        @MaSuKien = i.MaSuKien,
        @TinhTrang = ISNULL(i.TinhTrang, N'Chờ xác nhận'),
        @NgayDangKy = ISNULL(i.NgayDangKy, GETDATE())
    FROM inserted i;

    IF EXISTS (SELECT 1 FROM DangKy WHERE MaKhachMoi = @MaKhachMoi AND MaSuKien = @MaSuKien)
    BEGIN
        RAISERROR (N'Khách mời này đã đăng ký sự kiện này rồi.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO DangKy (MaKhachMoi, MaSuKien, TinhTrang, NgayDangKy)
        VALUES (@MaKhachMoi, @MaSuKien, @TinhTrang, @NgayDangKy);
    END;
END;
GO

CREATE LOGIN NhanVienMoi
    WITH PASSWORD = 'MatKhauBaoMat123!';
CREATE USER user_NV_Moi FOR LOGIN NhanVienMoi;

GRANT SELECT ON dbo.v_ChiTietDangKy TO user_NV_Moi;

GRANT EXECUTE ON dbo.sp_ThemDangKyMoi TO user_NV_Moi;

REVOKE EXECUTE ON dbo.sp_ThemDangKyMoi FROM user_NV_Moi;

CREATE ROLE NhanVienBaoCao;

GRANT SELECT ON dbo.v_ChiTietDangKy TO NhanVienBaoCao;

GRANT EXECUTE ON dbo.fn_DemSoNguoiDaXacNhan TO NhanVienBaoCao;

ALTER ROLE NhanVienBaoCao ADD MEMBER user_NV_Moi;
GO

ALTER ROLE NhanVienBaoCao DROP MEMBER user_NV_Moi;
	
DROP ROLE NhanVienBaoCao;

USE QuanLySuKien;
DROP USER user_NV_Moi;
GO

DROP LOGIN NhanVienMoi;
GO

EXECUTE AS USER = 'user_NV_Moi';

    PRINT N'--- Đang test với tư cách user_NV_Moi ---';
    SELECT TOP 5 * FROM v_ChiTietDangKy;

    BEGIN TRY
        SELECT * FROM NhaToChuc;
    END TRY
    BEGIN CATCH
        PRINT N'-> Lỗi dự kiến: Không có quyền truy cập bảng NhaToChuc.';
    END CATCH

REVERT;
PRINT N'--- Đã quay lại quyền Admin ---';
GO

USE master;
GO
BACKUP DATABASE QuanLySuKien
TO DISK = 'C:\BackupDB\QuanLySuKien_FULL.bak'
WITH INIT, NAME = 'Full Backup', STATS = 10;
GO

BACKUP DATABASE QuanLySuKien
TO DISK = 'C:\BackupDB\QuanLySuKien_DIFF.bak'
WITH DIFFERENTIAL, INIT, NAME = 'Diff Backup', STATS = 10;
GO

USE master;
GO

ALTER DATABASE QuanLySuKien
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

RESTORE DATABASE QuanLySuKien
FROM DISK = 'C:\BackupDB\QuanLySuKien_FULL.bak'
WITH REPLACE, RECOVERY;
GO

ALTER TABLE KhachMoi
ALTER COLUMN Email ADD MASKED WITH (FUNCTION = 'email()');

ALTER TABLE KhachMoi
ALTER COLUMN SoDienThoai ADD MASKED WITH (FUNCTION = 'partial(2, "xxxxx", 2)');
GO

EXECUTE AS USER = 'user_NV_Moi';
    SELECT TOP 5 TenKhachMoi, SoDienThoai, Email FROM KhachMoi;
REVERT;
GO

CREATE TABLE LichSuHuyDangKy (
    MaLog INT PRIMARY KEY IDENTITY(1,1),
    MaDangKy INT,
    NgayHuy DATETIME DEFAULT GETDATE(),
    NguoiThucHien NVARCHAR(100) DEFAULT ORIGINAL_LOGIN(),
    LyDo NVARCHAR(255)
);
GO

CREATE TRIGGER tr_GhiLogHuyDangKy
ON DangKy
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(TinhTrang)
    BEGIN
        INSERT INTO LichSuHuyDangKy (MaDangKy, LyDo)
        SELECT i.MaDangKy, N'Tự động ghi nhận hủy bởi hệ thống'
        FROM inserted i
        JOIN deleted d ON i.MaDangKy = d.MaDangKy
        WHERE i.TinhTrang = N'Đã hủy' AND d.TinhTrang != N'Đã hủy';
    END
END;
GO

UPDATE DangKy SET TinhTrang = N'Đã hủy' WHERE MaDangKy = 1;
SELECT * FROM LichSuHuyDangKy;
GO
