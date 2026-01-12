//
// PrivacyScreenManager.swift
// MomentumFinance
//
// Provides privacy screen functionality to blur/hide sensitive financial data
// when the app enters the background (App Switcher protection).
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Manager for app privacy screens to prevent data leakage in App Switcher.
public final class PrivacyScreenManager {
    
    public static let shared = PrivacyScreenManager()
    
    /// Whether privacy screen is currently active.
    private(set) var isPrivacyScreenActive = false
    
    #if canImport(UIKit)
    /// The privacy overlay view.
    private var privacyView: UIView?
    
    /// The window to add privacy view to.
    private weak var window: UIWindow?
    #endif
    
    private init() {}
    
    // MARK: - Configuration
    
    #if canImport(UIKit)
    /// Configures the privacy screen manager.
    /// - Parameter window: The main window to protect.
    public func configure(window: UIWindow) {
        self.window = window
        setupNotifications()
    }
    
    /// Sets up notification observers for app lifecycle events.
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // MARK: - Privacy Screen Control
    
    /// Shows the privacy screen (blur overlay).
    public func showPrivacyScreen() {
        guard let window = window, privacyView == nil else { return }
        
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = window.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add app logo/icon in center
        let logoImageView = UIImageView(image: UIImage(systemName: "dollarsign.circle.fill"))
        logoImageView.tintColor = .systemGreen
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Add to window
        window.addSubview(blurView)
        privacyView = blurView
        isPrivacyScreenActive = true
        
        print("[PrivacyScreen] Privacy screen activated")
    }
    
    /// Hides the privacy screen.
    public func hidePrivacyScreen() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.privacyView?.alpha = 0
        } completion: { [weak self] _ in
            self?.privacyView?.removeFromSuperview()
            self?.privacyView = nil
            self?.isPrivacyScreenActive = false
            print("[PrivacyScreen] Privacy screen deactivated")
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func applicationWillResignActive() {
        showPrivacyScreen()
    }
    
    @objc private func applicationDidBecomeActive() {
        hidePrivacyScreen()
    }
    #else
    // macOS stub
    public func configure(window: Any) {
        print("[PrivacyScreen] Privacy screen not supported on macOS")
    }
    
    public func showPrivacyScreen() {
        print("[PrivacyScreen] Privacy screen not supported on macOS")
    }
    
    public func hidePrivacyScreen() {
        print("[PrivacyScreen] Privacy screen not supported on macOS")
    }
    #endif
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
