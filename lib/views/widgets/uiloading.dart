part of 'widgets.dart';

class UiLoading {
  static Container loadingBlock() {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.black12,
      child: SpinKitFadingCircle(
        size: 50,
        color: Colors.amber.shade900,
      ),
    );
  }

  static Container loadingSmall() {
    return Container(
      alignment: Alignment.center,
      width: 30,
      height: 30,
      color: Colors.transparent,
      child: SpinKitFadingCircle(
        size: 30,
        color: Colors.amber.shade900,
      ),
    );
  }
}
