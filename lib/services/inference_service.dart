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

  img.Image FiFilter(img.Image originalImage, List<List<int>> filterMatrix) {
    // example filter matrix: var f0FilterMatrix =
    //                          [[0,0,0,0,0],
    //                           [0,0,0,0,0],
    //                           [1,1,1,1,1],
    //                           [0,0,0,0,0],
    //                           [0,0,0,0,0],];

    num getFilterMean(int row, int col) {
      var channelValue = 0.0; // No need for multiple channels; we only use blue channel values.

      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          if (filterMatrix[i][j] == 1) {
            var nx = row + j;
            var ny = col + i;

            if ((nx <= originalImage.width && nx >= 0) ||
                (ny <= originalImage.height && nx >= 0)) {

              channelValue += originalImage.getPixel(nx, ny).getChannel(img.Channel.blue);
              log(channelValue);
            }
          }
        }
      }
      return channelValue/5;
    }

    final FiImage =
        img.Image(width: originalImage.width, height: originalImage.height);
    for (int row = 0; row <= originalImage.height; row++) {
      for (int col = 0; col <= originalImage.width; col++) {
        var averageValue = getFilterMean(row, col);
        FiImage.setPixelRgb(row, col, averageValue, averageValue, averageValue);
      }
    }

    return FiImage;
  }
}
