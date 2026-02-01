import sys
import os
from unittest.mock import patch, mock_open

# Add root to path
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "../.."))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)

try:
    from MomentumFinance import add_missing_types
except ImportError:
    sys.path.append(os.path.abspath(os.path.join(current_dir, "..")))
    import add_missing_types


def test_add_file_to_project():
    """Test add_file_to_project function."""
    mock_content = """
/* End PBXFileReference section */
/* End PBXBuildFile section */
MomentumFinance = {
    children = (
    );
};
isa = PBXSourcesBuildPhase;
files = (
);
"""
    with (
        patch("builtins.open", mock_open(read_data=mock_content)) as mock_file,
        patch("builtins.print"),
    ):

        add_missing_types.add_file_to_project("dummy.pbxproj", "TestFile.swift")

        # Verify write occurred
        mock_file().write.assert_called()
        written_content = mock_file().write.call_args[0][0]
        assert "TestFile.swift" in written_content
        assert "isa = PBXFileReference" in written_content
        assert "isa = PBXBuildFile" in written_content
