import SwiftUI

struct ProjectDetailView: View {
    @Bindable var project: Project
    @StateObject private var playbackManager = PlaybackManager()
    @State private var selection: ViewMode = .stage2D
    
    @State private var showingSettings = false
    
    enum ViewMode: String, CaseIterable, Identifiable {
        case stage2D = "2D Stage"
        case stage3D = "3D Stage"
        case dancers = "Dancers"
        case groups = "Groups"
        case costumes = "Costumes"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack {
            Picker("View Mode", selection: $selection) {
                ForEach(ViewMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selection {
            case .stage2D:
                StageView2D(project: project, playbackManager: playbackManager)
            case .stage3D:
                StageView3D(project: project, playbackManager: playbackManager)
            case .dancers:
                DancerListView(project: project)
            case .groups:
                GroupListView(project: project)
            case .costumes:
                CostumeListView(project: project)
            }
            
            Spacer()
            
            TimelineView(project: project, playbackManager: playbackManager)
                .frame(height: 150)
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    if let pdfURL = PDFGenerator.generatePDF(for: project) {
                        ShareLink(item: pdfURL) {
                            Label("Export PDF", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    ScreenRecordingButton()
                    
                    Button(action: { showingSettings = true }) {
                        Label("Stage Settings", systemImage: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            if let config = project.stageConfig {
                NavigationStack {
                    StageConfigView(config: config)
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            playbackManager.setProject(project)
        }
        .onChange(of: project) { _, newProject in
            playbackManager.setProject(newProject)
        }
    }
}

// Placeholder Views

