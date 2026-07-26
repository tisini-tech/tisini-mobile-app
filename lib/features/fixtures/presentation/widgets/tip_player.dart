import 'package:flutter/material.dart';
import 'package:tisini/core/widgets/input_field.dart';
import 'package:tisini/shared/fixture_data/domain/entities/lineup.dart';

class TipPlayer extends StatefulWidget {
  final Lineup matchPlayer;

  const TipPlayer({super.key, required this.matchPlayer});

  @override
  State<StatefulWidget> createState() {
    return _TipPlayerState();
  }
}

class _TipPlayerState extends State<TipPlayer> {
  final GlobalKey<FormState> _tipKey = GlobalKey();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.matchPlayer;

    return AlertDialog(
      title: const Text('Enter M-pesa no. & Amount\n'),
      //  ListTile(
      //   // leading: CircleAvatar(child: Text(player.jerseyNo)),
      //   title: const Text(),
      //   subtitle: Text(player.pname),
      // ),
      content: Form(
        key: _tipKey,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                label: 'Phone no',
                errorMsg: 'phone no is required',
                hintText: 'Phone number',
                controller: phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a valid password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              InputField(
                label: 'Amount',
                errorMsg: 'Please enter amount',
                hintText: 'Amount ksh',
                controller: amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a valid password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_tipKey.currentState?.validate() ?? false) {
                      _tipKey.currentState?.save();
                    }
                  },
                  child: Text(
                    'Tip ${player.pname}',
                    overflow: TextOverflow.ellipsis,
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
