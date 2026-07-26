import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/container/circular_container.dart';
import 'package:tisini/core/widgets/container/curved_edges_widget.dart';
import 'package:flutter/material.dart';

class ContainerHeader extends StatelessWidget {
  const ContainerHeader({super.key, required this.child, this.height = 250});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CurvedEdgesWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: CircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: CircularContainer(
                  backgroundColor: TColors.textWhite.withOpacity(0.1),
                ),
              ),
              Positioned.fill(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
