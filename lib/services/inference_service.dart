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
      double channelValueSum = 0; // Only looking at blue channel; we normalized earlier
      int count = 0;
      int halfSize = filterMatrix.length ~/ 2;

      for (int matrixRow = 0; matrixRow < filterMatrix.length; matrixRow++) {
        for (int matrixCol = 0;
            matrixCol < filterMatrix[matrixRow].length;
            matrixCol++) {
          if (filterMatrix[matrixRow][matrixCol] == 1) {
            int nx = imgRow + matrixRow - halfSize;
            int ny = imgCol + matrixCol - halfSize;

            // Ensure the indices are within the image bounds
            if (nx >= 0 &&
                nx < sourceImage.height &&
                ny >= 0 &&
                ny < sourceImage.width) {
              channelValueSum += sourceImage.getPixel(ny, nx).getChannel(img.Channel.blue);
              count++;
            }
          }
        }
      }

      return count > 0 ? channelValueSum / count : 0;
    }

    final fiImage =
        img.Image(width: sourceImage.width, height: sourceImage.height);

    for (int row = 0; row < sourceImage.height; row++) {
      for (int col = 0; col < sourceImage.width; col++) {
        int averageValue = getFilterMean(row, col).round();
        fiImage.setPixelRgb(col, row, averageValue, averageValue, averageValue);
      }
    }

    return fiImage;
  }

  img.Image bottomHatFilter(img.Image image, List<List<int>> filterMatrix) {
    final dilatedImage = img.Image(width: image.width, height: image.height);
    final erodedImage = img.Image(width: image.width, height: image.height);
    final resultTestImage = img.Image(width: image.width, height: image.height);
    final halfSize = filterMatrix.length ~/ 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        num maxVal = 0;
        num minVal = 1000;
        for (int matrixRow = 0; matrixRow < filterMatrix.length; matrixRow++) {
          for (int matrixCol = 0; matrixCol < filterMatrix[matrixRow].length; matrixCol++) {
            if (filterMatrix[matrixRow][matrixCol]!=1){continue;};
            int nx = y + matrixRow - halfSize;
            int ny = x + matrixCol - halfSize;

            if (nx >= 0 &&
                nx < image.height &&
                ny >= 0 &&
                ny < image.width) {
            var currVal = image.getPixel(ny, nx).getChannel(img.Channel.blue);
            maxVal = (currVal > maxVal) ? currVal : maxVal;
            minVal = (currVal < minVal) ? currVal : minVal;
            }
          }
        }
        var resultVal = maxVal-minVal;
        resultTestImage.setPixelRgb(x, y, resultVal, resultVal, resultVal);
        dilatedImage.setPixelRgb(x, y, maxVal, maxVal, maxVal);
        erodedImage.setPixelRgb(x, y, minVal, minVal, minVal);
      }
    }

    return resultTestImage;
  }

  img.Image combineBottomHatResults(List<img.Image> images) {
    final combinedImage = img.Image(width: images[0].width, height: images[0].height);
    for (int y = 0; y < combinedImage.height; y++) {
      for (int x = 0; x < combinedImage.width; x++) {
        num sum = 0;
        for (final image in images) {
          sum += image.getPixel(x, y).getChannel(img.Channel.blue);
        }
        int combinedValue = sum ~/ images.length;
        combinedImage.setPixelRgb(x, y, combinedValue, combinedValue, combinedValue);
      }
    }
    return combinedImage;
  }

}
