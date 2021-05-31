// ...(name internalName: type)
public struct ParameterType {
	let rawValue: String
    let name: String
    let internalName: String
    let type: ClassType
}

extension ParameterType: CustomStringConvertible {
	public var description: String {
		"""
		  ---- Parameter name: \(name)
		  Internal name: \(internalName)
		  Type: \(type.name)
		  Contents:
		  \(rawValue)
		  ---- End of Parameter
		"""	
	}
}
