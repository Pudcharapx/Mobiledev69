import 'package:flutter/material.dart';
import '../core/constants/dormmate_constants.dart';
import '../core/localization/language_service.dart';
import '../models/room.dart';

class RoomCard extends StatelessWidget {
  final Room? room;

  const RoomCard({super.key, this.room});

  @override
  Widget build(BuildContext context) {
    final status = room?.status ?? 'Active';
    final isActive = status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A1F35),
            Color(0xFF0F1525),
            Color(0xFF1E1040),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DormMateDimens.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.20),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.50),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Ambient glow orb 1 — indigo upper right ───────────────────
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF667EEA).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Ambient glow orb 2 — violet bottom left ───────────────────
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF764BA2).withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Architectural watermark icon ──────────────────────────────
          const Positioned(
            right: -14,
            bottom: -22,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.apartment_rounded,
                size: 150,
                color: Colors.white,
              ),
            ),
          ),
          // ── Main content ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // MY ROOM badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_work_rounded,
                            size: 11,
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            context.isThai ? 'ห้องของฉัน' : 'MY ROOM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.90),
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Glowing status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981).withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF10B981).withValues(alpha: 0.40)
                              : Colors.white.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF10B981) : Colors.amber,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isActive ? const Color(0xFF10B981) : Colors.amber)
                                      .withValues(alpha: 0.75),
                                  blurRadius: 8,
                                  spreadRadius: 1.5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.isThai ? (isActive ? 'ใช้งานอยู่' : status) : status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? const Color(0xFF6EE7B7) : Colors.white70,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Room number — large display
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFD0CEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    room != null ? room!.displayLabel : 'B-204',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.near_me_outlined,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        room != null
                            ? (context.isThai
                                ? 'อาคาร ${room!.building} · ชั้น ${room!.floor} · ห้องพัก${room!.roomType == 'Twin' ? 'คู่' : room!.roomType}'
                                : '${room!.subtitle} · ${room!.roomType} Room')
                            : (context.isThai
                                ? 'อาคาร B · ชั้น 2 · ห้องพักคู่'
                                : 'Building B · 2nd Floor · Twin Room'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
