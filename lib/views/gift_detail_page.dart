import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:confetti/confetti.dart';
import '../controllers/gifts.dart';
import '../models/gift.dart';
import '../models/user.dart';

class GiftDetailPage extends StatefulWidget {
  final GiftModel? gift;
  final bool isOwner;
  const GiftDetailPage({super.key, this.gift, this.isOwner = false});
  @override
  _GiftDetailPageState createState() => _GiftDetailPageState();
}

class _GiftDetailPageState extends State<GiftDetailPage> {
  final GiftsController _giftsController = GiftsController.instance;
  final UserController _userController = UserController.instance;
  late ConfettiController _confettiController;

  bool isPledged = false;
  late Future<UserModel?> _user;
  String? pledgedUsername;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    if (widget.gift?.pledgedBy != null && widget.gift?.pledgedBy != "") {
      isPledged = true;
      _user = _userController
          .getUser(widget.gift!.pledgedBy!, context)
          .then((value) {
        if (mounted) {
          setState(() {
            isPledged = true;
            pledgedUsername = value?.username;
          });
        }
        return value;
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void pledge() async {
    await _giftsController.pledgeGift(widget.gift!, context);
    _showCelebration();
  }

  void _showCelebration() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        _confettiController.play();
        return Container(
          height: 200,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -pi / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 100,
                  minBlastForce: 80,
                  minimumSize: const Size(10, 10),
                  maximumSize: const Size(20, 20),
                  gravity: 0.2,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                    Colors.teal,
                    Colors.indigo,
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🎉',
                      style: TextStyle(fontSize: 50),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Gift Pledged Successfully!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Details"),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/app_icon.png',
              image: widget.gift!.giftImageUrl!,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/app_icon.png',
                    fit: BoxFit.cover);
              },
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.zero,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 12,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Gift Details',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        SizedBox(height: 30),
                        _buildDetailRow(
                            context,
                            'Gift Name:',
                            widget.gift?.name ?? 'N/A',
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            Icons.card_giftcard),
                        _buildDetailRow(
                            context,
                            'Price:',
                            '${widget.gift?.price.toString() ?? 'N/A'}',
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                            Icons.attach_money),
                        _buildDetailRow(
                            context,
                            'Category:',
                            widget.gift?.category.name ?? 'N/A',
                            Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.8),
                            Icons.category),
                        _buildDetailRow(
                            context,
                            'Description:',
                            widget.gift?.description ?? 'N/A',
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            Icons.description),
                        SizedBox(height: 20),
                        if (!widget.isOwner && !isPledged)
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pledge this gift:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.8),
                                          ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isPledged,
                                  onChanged: (value) {
                                    pledge();
                                    _user = _userController
                                        .getCurrentUser(context)
                                        .then((value) {
                                      if (mounted) {
                                        setState(() {
                                          isPledged = true;
                                          pledgedUsername = value?.username;
                                        });
                                      }
                                      return null;
                                    });
                                  },
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                        if (isPledged)
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Gift Status: ${widget.gift?.status.name}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.8),
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pledged by: ${pledgedUsername ?? 'Unknown'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.8),
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.onSurface),
                SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}