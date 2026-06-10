import SwiftUI

struct APITestView: View {
    @EnvironmentObject var settings: AppSettings

    @State private var password = ""
    @State private var birthDate = Date()
    @State private var selectedIndex = 0
    @State private var isLoading = false
    @State private var statusCode: Int?
    @State private var responseBody = ""
    @State private var errorMessage: String?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var endpoints: [FortuneEndpoint] { FortuneCatalog.endpoints }
    private var selected: FortuneEndpoint { endpoints[selectedIndex] }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [CyberTheme.blackPrimary, Color.black]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        authSection
                        endpointSection
                        executeButton
                        if let error = errorMessage { errorView(error) }
                        if statusCode != nil { resultView }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Rectangle().fill(CyberTheme.yellowAccent).frame(width: 4, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text("CYBER")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(CyberTheme.yellowAccent)
                Text("API TEST")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }

    // MARK: - 認証

    private var authSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("AUTH")
            if settings.isLoggedIn {
                HStack {
                    Image(systemName: "checkmark.seal.fill").foregroundColor(CyberTheme.limeGreen)
                    Text("ログイン済み: \(settings.authEmail)")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    Spacer()
                    Button("ログアウト") { settings.clearAuth() }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.red)
                }
            } else {
                TextField("email", text: $settings.authEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: login) {
                    Text("ログイン")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(CyberTheme.blackPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(CyberTheme.limeGreen)
                        .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    // MARK: - エンドポイント

    private var endpointSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("ENDPOINT")
            Menu {
                ForEach(endpoints) { ep in
                    Button(action: { selectedIndex = ep.id }) {
                        Text("\(ep.method) \(ep.label)")
                    }
                }
            } label: {
                HStack {
                    Text("\(selected.method) \(selected.label)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(CyberTheme.blackPrimary)
                        .lineLimit(1)
                    Spacer()
                    if selected.requiresAuth {
                        Image(systemName: "lock.fill").font(.system(size: 11))
                            .foregroundColor(CyberTheme.blackPrimary)
                    }
                    Image(systemName: "chevron.down").font(.system(size: 12))
                        .foregroundColor(CyberTheme.blackPrimary)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(CyberTheme.yellowAccent).cornerRadius(6)
            }

            Text(selected.path)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))

            HStack {
                Text("生年月日 (date/body 用)")
                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.7))
                Spacer()
                DatePicker("", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(CyberTheme.yellowAccent)
                    .colorScheme(.dark)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var executeButton: some View {
        Button(action: execute) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CyberTheme.blackPrimary))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "bolt.fill").font(.system(size: 18))
                }
                Text("EXECUTE")
                    .font(.system(size: 16, weight: .black, design: .monospaced)).tracking(2)
            }
            .foregroundColor(CyberTheme.blackPrimary)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(CyberTheme.yellowAccent).cornerRadius(8)
        }
        .disabled(isLoading)
    }

    private func errorView(_ error: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            Text(error).font(.system(size: 12, weight: .medium)).foregroundColor(.red)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6).fill(Color.red.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.5), lineWidth: 1))
        )
    }

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Rectangle().fill(statusColor).frame(width: 4, height: 20)
                Text("RESULT")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(statusColor)
                Spacer()
                Text("HTTP \(statusCode ?? -1)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(CyberTheme.blackPrimary)
                    .padding(.horizontal, 12).padding(.vertical, 4)
                    .background(statusColor).cornerRadius(4)
            }
            ScrollView(.horizontal, showsIndicators: true) {
                Text(responseBody)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .padding(12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.6))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(statusColor.opacity(0.4), lineWidth: 1))
            )
        }
    }

    private var statusColor: Color {
        guard let code = statusCode else { return CyberTheme.yellowAccent }
        return (200..<300).contains(code) ? CyberTheme.limeGreen : .red
    }

    // MARK: - パーツ

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundColor(CyberTheme.blackPrimary)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(CyberTheme.yellowAccent).cornerRadius(4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(CyberTheme.darkGray.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .foregroundColor(CyberTheme.yellowAccent.opacity(0.5))
            )
    }

    // MARK: - アクション

    private func login() {
        isLoading = true
        errorMessage = nil
        let api = FortuneTellingAPI(baseURL: settings.fortuneTellingServerURL)
        let email = settings.authEmail
        let pw = password
        Task {
            do {
                let tokens = try await api.login(email: email, password: pw)
                await MainActor.run {
                    settings.accessToken = tokens.accessToken
                    settings.refreshToken = tokens.refreshToken
                    password = ""
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func execute() {
        isLoading = true
        errorMessage = nil
        statusCode = nil
        responseBody = ""

        let api = FortuneTellingAPI(
            baseURL: settings.fortuneTellingServerURL,
            accessToken: settings.accessToken
        )
        let ep = selected
        let dateStr = dateFormatter.string(from: birthDate)

        if ep.requiresAuth && !settings.isLoggedIn {
            errorMessage = "このエンドポイントは認証が必要です。先にログインしてください。"
            isLoading = false
            return
        }

        Task {
            let resp = await api.execute(ep, birthdate: dateStr)
            await MainActor.run {
                statusCode = resp.statusCode
                responseBody = resp.body
                isLoading = false
            }
        }
    }
}
