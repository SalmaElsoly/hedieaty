import 'package:flutter/material.dart';

class GiftDetailPage extends StatefulWidget {
  const GiftDetailPage({super.key});
  @override
  _GiftDetailPageState createState() => _GiftDetailPageState();
}

class _GiftDetailPageState extends State<GiftDetailPage> {
  bool isPledged = false;

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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/app_icon.png'),
                fit: BoxFit.contain,
              ),
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
                            'iPhone 13',
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            Icons.card_giftcard),
                        _buildDetailRow(
                            context,
                            'Price:',
                            '\$1000',
                            Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                            Icons.attach_money),
                        _buildDetailRow(
                            context,
                            'Category:',
                            'Electronics',
                            Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.8),
                            Icons.category),
                        _buildDetailRow(
                            context,
                            'Description:',
                            'The latest iPhone',
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                            Icons.description),
                        SizedBox(height: 20),
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
                                    'Pledged:',
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
                                  setState(() {
                                    isPledged = value;
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
                        SizedBox(height: 10),
                        Center(
                          child: Text(
                            isPledged
                                ? 'Gift has been pledged!'
                                : 'Gift not pledged',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isPledged
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.8)
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
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
