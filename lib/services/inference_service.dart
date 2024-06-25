import 'dart:developer';
import 'dart:math';

import 'package:image/image.dart' as img;

class ImageAlgorithms {

  img.Image toGrayscaleUsingBlueChannel(img.Image originalImage) {
    final grayImage =
        img.Image(width: originalImage.width, height: originalImage.height);
    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        img.Pixel pixel = originalImage.getPixel(x, y);
        int blue = pixel.getChannel(img.Channel.blue).toInt();
        grayImage.setPixel(x, y, img.ColorRgb8(blue, blue, blue));
      }
    }
    return grayImage;
  }

  img.Image fiFilter(img.Image sourceImage, List<List<int>> filterMatrix) {
    // Applies Fi filter using a specified filter matrix, typically to emphasize certain directions.
    // The filter matrix is assumed to be 5x5. This function simulates the effect of a directional average filter.
    // Example filter matrix used to emphasize horizontal lines:
    // [
    //   [0,0,0,0,0],
    //   [0,0,0,0,0],
    //   [1,1,1,1,1],  // This row will contribute to the filtered image
    //   [0,0,0,0,0],
    //   [0,0,0,0,0],
    // ]

    double getFilterMean(int imgRow, int imgCol) {
      double channelValueSum = 0;
      int count = 0;

      for (int matrixRow = 0; matrixRow < 5; matrixRow++) {
        for (int matrixCol = 0; matrixCol < 5; matrixCol++) {
          if (filterMatrix[matrixRow][matrixCol] == 1) {
            int nx = imgRow + matrixRow - 2; // Center the filter matrix at (imgRow, imgCol)
            int ny = imgCol + matrixCol - 2;

            // Ensure the indices are within the image bounds
            if (nx >= 0 && nx < sourceImage.height && ny >= 0 && ny < sourceImage.width) {
              channelValueSum += sourceImage.getPixel(ny, nx).getChannel(img.Channel.blue); // Extract the blue channel
              count++;
            }
          }
        }
      }

      return count > 0 ? channelValueSum / count : 0; // Return the average or 0 if count is zero
    }

    // Create a new image with the same dimensions as the source image
    final fiImage = img.Image(width: sourceImage.width, height: sourceImage.height);

    // Apply the filter to each pixel in the source image
    for (int row = 0; row < sourceImage.height; row++) {
      for (int col = 0; col < sourceImage.width; col++) {
        int averageValue = getFilterMean(row, col).round();
        fiImage.setPixelRgb(col, row, averageValue, averageValue, averageValue);
      }
    }

    return fiImage;
  }
}
