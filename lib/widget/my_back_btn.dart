import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/dimens.dart';

class MyBackBtn extends StatelessWidget {
  Function()  onPressed;
   MyBackBtn({required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: Dimens.small,
        left: Dimens.small,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(2, 3), blurRadius: 20, color: Colors.black26)
              ]),
          child: IconButton(
            onPressed:onPressed,
            icon: const Icon(Icons.arrow_back),
          ),
        ));
  }
}
