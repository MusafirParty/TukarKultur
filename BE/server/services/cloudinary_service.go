package services

import (
	"context"
	"mime/multipart"
	"os"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

type CloudinaryService struct {
	cld *cloudinary.Cloudinary
}

func NewCloudinaryService() *CloudinaryService {
	cld, _ := cloudinary.NewFromParams(
		os.Getenv("CLOUDINARY_CLOUD_NAME"),
		os.Getenv("CLOUDINARY_API_KEY"),
		os.Getenv("CLOUDINARY_API_SECRET"),
	)
	return &CloudinaryService{cld: cld}
}

func (s *CloudinaryService) UploadImage(file multipart.File, folder string) (*uploader.UploadResult, error) {
	ctx := context.Background()
	uploadParams := uploader.UploadParams{
		Folder: folder,
	}
	return s.cld.Upload.Upload(ctx, file, uploadParams)
}
