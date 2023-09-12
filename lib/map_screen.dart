import 'package:flutter/material.dart';
import 'package:snapp_app/res/dimens.dart';
import 'package:snapp_app/res/text_style.dart';
import 'package:snapp_app/widget/my_back_btn.dart';

class CurrentWidgetState {
  CurrentWidgetState._();
  static const selectOriginState = 0;
  static const selectDesinationState = 1;
  static const requestDriverState = 2;
}

class MappScreen extends StatefulWidget {
  const MappScreen({super.key});

  @override
  State<MappScreen> createState() => _MappScreenState();
}

class _MappScreenState extends State<MappScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.blueGrey,
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.larg),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'انتخاب مبدأ',
                      style: MyTextStyles.button,
                    ),
                  ),
                )),
            MyBackBtn(
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
