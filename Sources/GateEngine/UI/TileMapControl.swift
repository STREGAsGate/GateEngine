//
//  TileMapControl.swift
//  GateEngine
//
//  Created by Dustin Collins on 5/1/25.
//

public enum TileMapControlState: Int, CaseIterable {
    case regular        = 0
    case highlighted    = 1
    case selected       = 2
    case disabled       = 3
}

public enum TileMapControlType {
    /// The control automatically deselects upon selection
    case momentary
    /// Only 1 element can be selected within the control
    case segmented
    /// Any element can be selected within the control
    case toggleable
}

public enum TileMapControlSubControlType: Sendable {
    case decorative
    case interactable
}

public protocol TileControlSubControl<Scheme>: Equatable, Hashable, Identifiable where Control.Scheme == Scheme, ID == Int {
    associatedtype Scheme: TileMapControlScheme
    associatedtype Control: TileControl
    
    var type: TileMapControlSubControlType { get }
    /// The arangement of coordinates (relative to zero) for this control.
    /// The position of this control is determined by TileMapControlScheme
    var coordinates: [TileMap.Layer.Coordinate] { get }
    /// The `regular` state tile for the layer
    func regularStateTile(at coordinateIndex: Int, forLayer layer: String?, mode: Scheme.Mode, userData: Scheme.UserData) -> TileMap.Tile
}

public extension TileControlSubControl {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public protocol TileControl<Scheme>: Equatable, Identifiable where ID == String {
    associatedtype Scheme: TileMapControlScheme
    associatedtype SubControl: TileControlSubControl<Scheme>
    /// How this control behaves
    var type: TileMapControlType { get }
    var subControls: [SubControl] { get }
    
    func currentStateForSubControl(_ subControl: any TileControlSubControl<Scheme>, mode: Scheme.Mode, userData: Scheme.UserData) -> TileMapControlState
    func stateDidChangeForSubControl(_ subControl: any TileControlSubControl<Scheme>, state: TileMapControlState, mode: Scheme.Mode, userData: inout Scheme.UserData)
}

public protocol TileMapControlScheme {
    associatedtype Mode: TileMapControlMode
    associatedtype UserData: TileMapControlUserData
    static func control(at coordinate: TileMap.Layer.Coordinate, forMode mode: Mode, userData: UserData) -> (any TileControl<Self>)?
}

public protocol TileMapControlUserData: Equatable, Hashable, Sendable {
    init()
}

public protocol TileMapControlMode: Equatable, Hashable, CaseIterable, Sendable {
    static var `default`: Self { get }
}

@MainActor
public protocol TileMapControlViewDelegate<Scheme>: AnyObject {
    associatedtype Scheme: TileMapControlScheme
    func tileMapControlView(_ tileMapControl: TileMapControlView<Scheme>, didActivateControl control: any TileControl<Scheme>, subControlIndex: Int)
}

public final class TileMapControlView<Scheme: TileMapControlScheme>: TileMapView {
    private func baseOffset(forState state: TileMapControlState) -> Int {
        let count = tileSet.tiles.count / TileMapControlState.allCases.count
        return state.rawValue * count
    }
    
    var modeDidChange: Bool = true
    public var mode: Scheme.Mode = Scheme.Mode.default {
        didSet {self.modeDidChange = true}
    }
    public weak var controlDelegate: (any TileMapControlViewDelegate<Scheme>)? = nil
        
    public var userData: Scheme.UserData = .init()
    
    var controls: [any TileControl<Scheme>] = []
    var controlOrigins: [TileMap.Layer.Coordinate] = []
    var controlIndicies: [Int?] = []
    var controlStates: [[TileMapControlState]] = []

    private func rebuildForCurrentMode() {
        self.controlIndicies = Array(repeating: nil, count: layers[0].columns * layers[0].rows)
        self.controls.removeAll(keepingCapacity: true)
        self.controlOrigins.removeAll(keepingCapacity: true)
        self.controlStates.removeAll(keepingCapacity: true)
        self.eraseAllLayers()
        
        guard let layer = tileMap.layers.first else {return}
        
        for column in 0 ..< layer.columns {
            for row in 0 ..< layer.rows {
                let origin = TileMap.Layer.Coordinate(column: column, row: row)
                if let control = Scheme.control(at: origin, forMode: mode, userData: userData) {
                    let controlIndex = controls.endIndex
                    self.controls.append(control)
                    self.controlOrigins.append(origin)
                    var states: [TileMapControlState] = []
                    var controlOriginIsASubControl = false
                    for subControlIndex in control.subControls.indices {
                        let subControl = control.subControls[subControlIndex]
                        states.append(control.currentStateForSubControl(subControl, mode: mode, userData: userData))
                        for coordIndex in subControl.coordinates.indices {
                            let coord = subControl.coordinates[coordIndex]
                            if coord == .init(column: 0, row: 0) {
                                controlOriginIsASubControl = true
                            }
                            let coordIndex: Int = self.coordIndex(of: origin + coord)
                            assert(controlIndicies[coordIndex] == nil, "TileControl \(control.id) overlaps an existing control.")
                            controlIndicies[coordIndex] = controlIndex
                        }
                    }
                    assert(controlOriginIsASubControl, "A TileControl origin must be a sub control of that control.")
                    self.controlStates.append(states)
                    self.repaintControl(at: .init(column: column, row: row))
                }
            }
        }
    }
    
    private func coordIndex(of coord: TileMap.Layer.Coordinate) -> Int {
        let width = Int(tileMap.size.width)
        return (coord.row * width) + coord.column
    }
    
    private func coord(of coordIndex: Int) -> TileMap.Layer.Coordinate {
        let width = Int(tileMap.size.width)
        let row = coordIndex / width
        let column = coordIndex % width
        return .init(column: column, row: row)
    }
    
    func control(at coord: TileMap.Layer.Coordinate) -> (control: any TileControl<Scheme>, subControlIndex: Int)? {
        let coordIndex = coordIndex(of: coord)
        if let controlIndex = controlIndicies[coordIndex] {
            let control = controls[controlIndex]
            let offset = controlOrigins[controlIndex]
            for subControlIndex in control.subControls.indices {
                let subControl = control.subControls[subControlIndex]
                for coordIndex in subControl.coordinates.indices {
                    let subControlCoord = subControl.coordinates[coordIndex] + offset
                    if subControlCoord == coord {
                        return (control, subControlIndex)
                    }
                }
            }
        }
        return nil
    }
    
    func state(forControl control: any TileControl, subControlIndex: Int) -> TileMapControlState {
        let controlIndex = self.controls.firstIndex(where: {$0.id == control.id})!
        let coordIndex = controlIndicies.first(where: {$0 == controlIndex})!!
        return controlStates[coordIndex][subControlIndex]
    }
    func setState(_ state: TileMapControlState, forControl control: any TileControl, subControlIndex: Int) {
        let controlIndex = self.controls.firstIndex(where: {$0.id == control.id})!
        let coordIndex = controlIndicies.firstIndex(where: {$0 == controlIndex})!
        self.controlStates[controlIndicies[coordIndex]!][subControlIndex] = state
        let coord = coord(of: coordIndex)
        self.repaintControl(at: coord)
    }
    
    func eraseAllLayers() {
        for layer in self.layers {
            self.editLayer(named: layer.name!) { layer in
                for column in 0 ..< layer.columns {
                    for row in 0 ..< layer.rows {
                        layer.setTile(.empty, at: .init(column: column, row: row))
                    }
                }
            }
        }
    }
    
    public func repaintControl(at coord: TileMap.Layer.Coordinate) {
        guard modeDidChange == false else {return}
        guard let controlIndex = controlIndicies[coordIndex(of: coord)] else {return}
        let control = controls[controlIndex]
        let offset = controlOrigins[controlIndex]
        for layer in tileMap.layers {
            for subControlIndex in control.subControls.indices {
                let subControl = control.subControls[subControlIndex]
                var state = self.state(forControl: control, subControlIndex: subControlIndex)
                self.editLayer(named: layer.name!) { layer in
                    for coordIndex in subControl.coordinates.indices {
                        let coord = subControl.coordinates[coordIndex] + offset
                        let tile = subControl.regularStateTile(at: coordIndex, forLayer: layer.name, mode: mode, userData: userData)
                        if tile == .empty {continue}
                        if subControl.type != .decorative && state != .disabled && state != .selected {
                            if let tempHighlighted = hid.activeHover {
                                if subControl.coordinates.contains(where: {$0 + offset == tempHighlighted}) {
                                    state = .highlighted
                                }
                            }
                            if let tempSelected = hid.activeSelect {
                                if subControl.coordinates.contains(where: {$0 + offset == tempSelected}) {
                                    state = .selected
                                }
                            }
                        }
                        let offset = baseOffset(forState: state)
                        layer.setTile(.id(tile.id + offset, tile.options), at: coord)
                    }
                }
            }
        }
    }
    
    public override func update(withTimePassed deltaTime: Float) {
        super.update(withTimePassed: deltaTime)
        guard isReady else {return}
        if self.modeDidChange {
            self.modeDidChange = false
            self.rebuildForCurrentMode()
        }
        self.updateHID(withTimePassed: deltaTime)
        self.updateMomentaryToDeactivate(withTimePassed: deltaTime)
    }
    
    public override func canBeHit() -> Bool {
        return true
    }

    public override func didLoadLayers() {
        super.didLoadLayers()
        
    }
    
    var momentaryToDeactivate: [(pair: (control: any TileControl<Scheme>, subControlIndex: Int), duration: Float)] = []
    func updateMomentaryToDeactivate(withTimePassed deltaTime: Float) {
        for index in momentaryToDeactivate.indices.reversed() {
            momentaryToDeactivate[index].duration -= deltaTime
            let momentary = momentaryToDeactivate[index]
            if momentary.duration < 0 {
                self.momentaryToDeactivate.remove(at: index)
                self.setState(.regular, forControl: momentary.pair.control, subControlIndex: momentary.pair.subControlIndex)
                
                let subControl = momentary.pair.control.subControls[momentary.pair.subControlIndex]
                momentary.pair.control.stateDidChangeForSubControl(subControl, state: .regular, mode: mode, userData: &userData)
            }
        }
    }
    
    private func didActiveControl(at coord: TileMap.Layer.Coordinate) {
        guard let pair = control(at: coord) else {return}
        guard pair.control.subControls[pair.subControlIndex].type != .decorative else {return}
        
        var activate: Bool = false
        
        switch pair.control.type {
        case .momentary:
            let currentState = self.state(forControl: pair.control, subControlIndex: pair.subControlIndex)
            guard currentState != .selected && currentState != .disabled else { return }
            self.setState(.selected, forControl: pair.control, subControlIndex: pair.subControlIndex)
            self.momentaryToDeactivate.append((pair, 0.03))
            pair.control.stateDidChangeForSubControl(pair.control.subControls[pair.subControlIndex], state: .selected, mode: mode, userData: &userData)
            activate = true
        case .segmented:
            let currentState = self.state(forControl: pair.control, subControlIndex: pair.subControlIndex)
            guard currentState != .selected && currentState != .disabled else { return }
            for subControlIndex in pair.control.subControls.indices {
                let state: TileMapControlState
                if subControlIndex == pair.subControlIndex {
                    state = .selected
                }else{
                    let currentState = self.state(forControl: pair.control, subControlIndex: subControlIndex)
                    if currentState == .selected {
                        // Deselect the old value
                        state = .regular
                    }else{
                        state = currentState
                    }
                }
                
                // Update the state if it's different
                if self.state(forControl: pair.control, subControlIndex: subControlIndex) != state {
                    self.setState(state, forControl: pair.control, subControlIndex: subControlIndex)
                    pair.control.stateDidChangeForSubControl(pair.control.subControls[pair.subControlIndex], state: state, mode: mode, userData: &userData)
                    activate = true
                }
            }
        case .toggleable:
            let currentState = self.state(forControl: pair.control, subControlIndex: pair.subControlIndex)
            guard currentState != .selected && currentState != .disabled else { return }
            let state: TileMapControlState = if currentState == .selected {
                .regular
            }else{
                .selected
            }
            self.setState(state, forControl: pair.control, subControlIndex: pair.subControlIndex)
            pair.control.stateDidChangeForSubControl(pair.control.subControls[pair.subControlIndex], state: state, mode: mode, userData: &userData)
            activate = true
        }
        
        if activate {
            self.controlDelegate?.tileMapControlView(self, didActivateControl: pair.control, subControlIndex: pair.subControlIndex)
        }
    }
    
    private var _hidOld: HIDState = .init()
    private var hid: HIDState = .init()
    
    func updateHID(withTimePassed deltaTime: Float) {
        guard hid != _hidOld else {return}
        defer { self._hidOld = self.hid }
        
        if let oldHighlight = self._hidOld.activeHover {
            self.repaintControl(at: oldHighlight)
        }
        if let highlight = self.hid.activeHover {
            self.repaintControl(at: highlight)
        }
        if let oldSelect = self._hidOld.activeSelect {
            self.repaintControl(at: oldSelect)
        }
        if let select = self.hid.activeSelect {
            self.repaintControl(at: select)
        }
    }

    struct HIDState: Equatable {
        var activeHover: TileMap.Layer.Coordinate? = nil
        var activeSelect: TileMap.Layer.Coordinate? = nil
        
    }
    func hid_coordFromPosition(_ p: Position2) -> TileMap.Layer.Coordinate? {
        let x = Int(p.x / (self.frame.width / layers.first!.size.width))
        let y = Int(p.y / (self.frame.height / layers.first!.size.height))
        return .init(column: x, row: y)
    }
    func hid_clear() {
        self.hid = .init()
    }
    func hid_moved(at p: Position2) {
        self.hid.activeHover = self.hid_coordFromPosition(p)
    }
    func hid_beginAction(at p: Position2) {
        self.hid.activeSelect = self.hid_coordFromPosition(p)
    }
    
    func hid_endAction(at p: Position2) {
        defer {
            self.hid.activeSelect = nil
        }
        guard let selected = self.hid_coordFromPosition(p) else {return}
        guard let selecting = self.hid.activeSelect, selecting == selected else {return}
        self.didActiveControl(at: selected)
    }
    
    func hid_cancel() {
        self.hid_clear()
    }

    public override func cursorMoved(_ cursor: Mouse) {
        super.cursorMoved(cursor)
        guard let cursorPosition = cursor.locationInView(self) else {return}
        self.hid_moved(at: cursorPosition)
    }
    
    public override func cursorExited(_ cursor: Mouse) {
        super.cursorExited(cursor)
        self.hid_cancel()
    }
    
    public override func cursorButtonDown(button: MouseButton, mouse: Mouse) {
        super.cursorButtonDown(button: button, mouse: mouse)
        guard button == .primary else {return}
        guard let cursorPosition = mouse.locationInView(self) else {return}
        self.hid_beginAction(at: cursorPosition)
    }
    
    public override func cursorButtonUp(button: MouseButton, mouse: Mouse) {
        super.cursorButtonUp(button: button, mouse: mouse)
        guard button == .primary else {return}
        guard let cursorPosition = mouse.locationInView(self) else {return}
        self.hid_endAction(at: cursorPosition)
    }
    
    var activeTouch: Touch? = nil
    public override func touchesBegan(_ touches: Set<Touch>) {
        super.touchesBegan(touches)
        guard self.activeTouch == nil else {return}
        guard let touch = touches.first else {return}
        self.activeTouch = touch
        
        self.hid_beginAction(at: touch.locationInView(self))
    }
    
    public override func touchesMoved(_ touches: Set<Touch>) {
        super.touchesMoved(touches)
        guard let touch = touches.first(where: {$0 == activeTouch}) else {return}
        
        self.hid_moved(at: touch.locationInView(self))
    }
    
    public override func touchesEnded(_ touches: Set<Touch>) {
        super.touchesEnded(touches)
        guard let touch = touches.first(where: {$0 == activeTouch}) else {return}
        
        self.hid_endAction(at: touch.locationInView(self))
        self.activeTouch = nil
    }
    
    public override func touchesCanceled(_ touches: Set<Touch>) {
        super.touchesCanceled(touches)
        guard touches.first(where: {$0 == activeTouch}) != nil else {return}
        self.activeTouch = nil
        self.hid_cancel()
    }
}
